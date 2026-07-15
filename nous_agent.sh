#!/data/data/com.termux/files/usr/bin/bash
#
# ☤ Hermes Agent for Android (Termux) — One-Line Installer
# Repository: https://github.com/fbscotta369/Hermes-Agent-On-Android
#
# A self-evolving AI framework by Nous Research, packaged for Android.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/nous_agent.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/nous_agent.sh | bash -s -- --edge
#   curl -fsSL .../nous_agent.sh | bash -s -- --tag v2026.7.7.2
#
set -euo pipefail

# ──────────────────────────────────────────────
# Colors
# ──────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
RST='\033[0m'

# ──────────────────────────────────────────────
# Configuration (overridable via flags)
# ──────────────────────────────────────────────
HERMES_REPO="https://github.com/NousResearch/hermes-agent.git"
HERMES_TAG="v2026.7.7.2"   # Stable release used by default
USE_EDGE=false
CUSTOM_TAG=""

# ──────────────────────────────────────────────
# Parse arguments
# ──────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --edge)     USE_EDGE=true ;;
        --stable)   USE_EDGE=false ;;
        --tag=*)    CUSTOM_TAG="${arg#*=}" ;;
        --help|-h)
            echo "Usage: curl -fsSL .../nous_agent.sh | bash [-- <flags>]"
            echo ""
            echo "Flags:"
            echo "  --edge          Track Hermes Agent main branch (latest, potentially unstable)"
            echo "  --stable        Use the pinned stable release (default)"
            echo "  --tag=vX.Y.Z    Pin to a specific release tag"
            echo "  --help, -h      Show this help"
            exit 0
            ;;
    esac
done

# Apply overrides
if [ -n "$CUSTOM_TAG" ]; then
    HERMES_TAG="$CUSTOM_TAG"
    USE_EDGE=false
fi

# ──────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────
step()   { echo -e "${GRN}━━━ ${CYN}$*${RST}"; }
info()   { echo -e "${GRN}  → $*${RST}"; }
warn()   { echo -e "${YLW}  ⚠️  $*${RST}"; }
fail()   { echo -e "${RED}  ❌ $*${RST}"; exit 1; }
ok()     { echo -e "${GRN}  ✅ $*${RST}"; }

cleanup() {
    [ -n "${INNER_SCRIPT:-}" ] && rm -f "$INNER_SCRIPT"
    termux-wake-unlock 2>/dev/null || true
}
trap cleanup EXIT

# ──────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────
clear
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}         ☤  HERMES AGENT FOR ANDROID  ☤${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}                AIIA-Labs"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

# ──────────────────────────────────────────────
# [Improvement #8] Pre-flight environment checks
# ──────────────────────────────────────────────
step "Pre-flight checks"

# --- Android version ---
ANDROID_SDK=$(getprop ro.build.version.sdk 2>/dev/null || echo 0)
if [ "$ANDROID_SDK" -eq 0 ]; then
    warn "Could not detect Android API level. Not in Termux? Continuing anyway..."
elif [ "$ANDROID_SDK" -lt 30 ]; then
    fail "Android 11+ (API 30+) required. Found API ${ANDROID_SDK}."
else
    ok "Android API ${ANDROID_SDK}"
fi

# --- Storage space (at least 3 GB free) ---
if command -v df &>/dev/null; then
    AVAIL_MB=$(df -m /data 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)
    if [ "$AVAIL_MB" -gt 0 ] && [ "$AVAIL_MB" -lt 3000 ]; then
        fail "At least 3 GB free storage required. Found ~$((AVAIL_MB / 1024)) GB."
    elif [ "$AVAIL_MB" -ge 3000 ]; then
        ok "Storage: ~$((AVAIL_MB / 1024)) GB free"
    else
        warn "Could not check storage space"
    fi
fi

# --- Internet connectivity ---
if ! curl -s --max-time 10 https://github.com >/dev/null 2>&1; then
    fail "No internet connectivity detected. Check your connection."
fi
ok "Internet connected"

# --- Keep device awake ---
termux-wake-lock 2>/dev/null || true

# ──────────────────────────────────────────────
# Install proot-distro + Ubuntu
# ──────────────────────────────────────────────
step "Setting up proot-distro environment"

info "Installing / updating proot-distro..."
if ! pkg install proot-distro -y 2>&1; then
    fail "Failed to install proot-distro"
fi
ok "proot-distro ready"

# [Improvement #1] Ubuntu detection — robust against different output formats
info "Checking Ubuntu installation..."

# Multiple detection strategies to handle varying proot-distro output formats
UBUNTU_INSTALLED=false
if proot-distro list 2>/dev/null | grep -qi "ubuntu"; then
    if proot-distro list 2>/dev/null | grep -qi "ubuntu.*Installed: yes\|ubuntu.*installed" 2>/dev/null; then
        UBUNTU_INSTALLED=true
    elif proot-distro list 2>/dev/null | grep -qi "ubuntu" | grep -qi "yes" 2>/dev/null; then
        UBUNTU_INSTALLED=true
    elif [ -d "$PREFIX/var/lib/proot-distro/installed-distros/ubuntu" ]; then
        UBUNTU_INSTALLED=true
    fi
fi

if [ "$UBUNTU_INSTALLED" = true ]; then
    ok "Ubuntu is already installed"
else
    info "Installing Ubuntu (this may take a few minutes)..."
    # Try install; handle "already exists" error gracefully
    if ! OUTPUT=$(proot-distro install ubuntu 2>&1); then
        if echo "$OUTPUT" | grep -qi "already exists"; then
            warn "Ubuntu container already exists (detection hiccup). Continuing..."
        else
            fail "Failed to install Ubuntu: $OUTPUT"
        fi
    fi
    ok "Ubuntu ready"
fi

# ──────────────────────────────────────────────
# [Improvement #10] Write inner install script to temp file
# ──────────────────────────────────────────────
step "Installing Hermes Agent inside Ubuntu"

INNER_SCRIPT=$(mktemp)

cat > "$INNER_SCRIPT" << INNER_EOF
#!/bin/bash
# [Improvement #2] Strict mode inside inner script
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Passed in from outer script
HERMES_TAG='${HERMES_TAG}'
USE_EDGE=${USE_EDGE}
HERMES_REPO='${HERMES_REPO}'

echo "  → Updating Ubuntu packages..."
apt-get update -qq
apt-get upgrade -y -o Dpkg::Options::="--force-confold" >/dev/null 2>&1 || true

echo "  → Installing system dependencies..."
apt-get install -y -o Dpkg::Options::="--force-confold" \
    git curl wget build-essential \
    nodejs npm \
    libffi-dev libssl-dev pkg-config \
    ca-certificates >/dev/null 2>&1

# Hermes Agent requires Python >=3.11, <3.14
# Ubuntu 25.04+ ships Python 3.14 which is incompatible
# Solution: use uv which automatically manages Python versions
echo "  → Installing uv (Python package manager with auto version management)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="\$HOME/.local/bin:\$PATH"
echo "  → uv installed: \$(uv --version 2>/dev/null || echo 'ready')"

REPO_DIR="\$HOME/hermes-agent"

# --- Clone or update the Hermes Agent repository ---
if [ -d "\$REPO_DIR/.git" ]; then
    echo "  → Updating existing hermes-agent repository..."
    cd "\$REPO_DIR"
    git fetch origin
    if [ "\$USE_EDGE" = "true" ]; then
        git reset --hard origin/main
    else
        git fetch --tags
        if git rev-parse --verify "\$HERMES_TAG" >/dev/null 2>&1; then
            git checkout "\$HERMES_TAG"
        else
            echo "  ⚠️  Tag \$HERMES_TAG not found locally, checking out origin/main"
            git reset --hard origin/main
        fi
    fi
else
    echo "  → Cloning Hermes Agent repository..."
    rm -rf "\$REPO_DIR"
    if [ "\$USE_EDGE" = "true" ]; then
        git clone --depth 1 --recurse-submodules --shallow-submodules \
            "\$HERMES_REPO" "\$REPO_DIR"
    else
        echo "  → Using stable release: \$HERMES_TAG"
        git clone --depth 1 --branch "\$HERMES_TAG" --recurse-submodules --shallow-submodules \
            "\$HERMES_REPO" "\$REPO_DIR"
    fi
    cd "\$REPO_DIR"
fi

cd "\$REPO_DIR"

# --- Python virtual environment (uv manages the Python version automatically) ---
echo "  → Setting up Python virtual environment with compatible Python..."
rm -rf venv
uv venv --python ">=3.11,<3.14" venv
source venv/bin/activate

echo "  → Python version: \$(python --version)"

echo "  → Upgrading pip..."
uv pip install --upgrade pip setuptools wheel

echo "  → Installing Hermes Agent (this can take 5-10 minutes)..."
if ! uv pip install -e ".[all]" >/dev/null 2>&1; then
    echo "  ⚠️  Full extras install failed, trying base install..."
    uv pip install -e "."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Hermes Agent installed inside Ubuntu!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
INNER_EOF

if ! proot-distro login ubuntu -- bash "$INNER_SCRIPT"; then
    fail "Installation inside Ubuntu failed"
fi

# ──────────────────────────────────────────────
# [Improvement #3] Install Termux-level 'hermes' launcher
# Eliminates: cd → proot-distro login ubuntu → cd hermes-agent → source venv/bin/activate → hermes
# ──────────────────────────────────────────────
step "Installing 'hermes' command for Termux"

# --- Main hermes launcher ---
cat > "$PREFIX/bin/hermes" << 'HERMES_LAUNCHER'
#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent launcher — transparently enters Ubuntu + venv
# Usage: hermes [args...]
#
exec proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" && source venv/bin/activate && exec hermes "$@"
' -- "$@"
HERMES_LAUNCHER
chmod +x "$PREFIX/bin/hermes"
ok "Created $PREFIX/bin/hermes"

# --- hermes-setup launcher ---
cat > "$PREFIX/bin/hermes-setup" << 'HERMES_SETUP'
#!/data/data/com.termux/files/usr/bin/bash
#
# One-shot Hermes Agent first-time setup
# Usage: hermes-setup
#
exec proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" && source venv/bin/activate && exec hermes setup "$@"
' -- "$@"
HERMES_SETUP
chmod +x "$PREFIX/bin/hermes-setup"
ok "Created $PREFIX/bin/hermes-setup"

# --- hermes-gateway launcher (with Telegram notifications + error diagnostics) ---
cat > "$PREFIX/bin/hermes-gateway" << 'HERMES_GATEWAY'
#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent gateway launcher with Telegram notifications + error diagnostics
# Usage: hermes-gateway
#
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; RST='\033[0m'

send_telegram() {
    [ -z "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${HERMES_TELEGRAM_CHAT_ID:-}" ] && return 0
    curl -s -X POST "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${HERMES_TELEGRAM_CHAT_ID}" -d text="$1" --max-time 10 >/dev/null 2>&1 || true
}

OFFLINE_SENT=false
send_offline() {
    [ "$OFFLINE_SENT" = "false" ] && OFFLINE_SENT=true && send_telegram "Hermes Agent Gateway offline :-("
}
trap send_offline EXIT

# Check API key exists before starting
check_api_key() {
    if [ -z "${GOOGLE_API_KEY:-}" ] && [ -z "${GEMINI_API_KEY:-}" ] && \
       [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        echo -e "${RED}❌ No API key found! Set GOOGLE_API_KEY, OPENAI_API_KEY, or ANTHROPIC_API_KEY in ~/.bashrc${RST}"
        send_telegram "Hermes Agent Gateway failed: No API key configured!"
        exit 1
    fi
}
check_api_key

# Show provider
if [ -n "${GOOGLE_API_KEY:-}" ] || [ -n "${GEMINI_API_KEY:-}" ]; then
    echo -e "${CYN}  Provider: Google Gemini${RST}"
elif [ -z "${OPENAI_API_KEY:-}" ] && [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo -e "${CYN}  Provider: Anthropic${RST}"
elif [ -n "${OPENAI_API_KEY:-}" ]; then
    echo -e "${CYN}  Provider: OpenAI${RST}"
fi

send_telegram "Hermes Agent Gateway online ;-)"

# Start gateway (no exec — trap needs the process to return)
GATEWAY_EXIT=0
proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" && source venv/bin/activate && exec hermes gateway "$@"
' -- "$@" || GATEWAY_EXIT=$?

# Show diagnostic help on failure
if [ "$GATEWAY_EXIT" -ne 0 ]; then
    echo ""
    echo -e "${RED}━━━ Gateway exited with errors ━━━${RST}"
    echo -e "  ${YLW}Common causes:${RST}"
    echo -e "    1. API key invalid/expired → re-generate at provider dashboard"
    echo -e "    2. API key not set → run ${CYN}hermes-doctor${RST}"
    echo -e "    3. Provider API down → try again later"
    echo ""
    echo -e "  ${YLW}Debug:${RST} proot-distro login ubuntu → cd hermes-agent → hermes gateway --log-level debug"
    send_telegram "Hermes Agent Gateway failed (exit $GATEWAY_EXIT). Run: hermes-doctor"
fi
HERMES_GATEWAY
chmod +x "$PREFIX/bin/hermes-gateway"
ok "Created $PREFIX/bin/hermes-gateway"

# --- hermes-doctor diagnostic launcher ---
cat > "$PREFIX/bin/hermes-doctor" << 'HERMES_DOCTOR'
#!/data/data/com.termux/files/usr/bin/bash
# Hermes Agent Doctor — runs diagnostics inside Ubuntu
exec proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" 2>/dev/null && source venv/bin/activate 2>/dev/null
# Run the full diagnostic
RED="\033[0;31m"; GRN="\033[0;32m"; YLW="\033[1;33m"; CYN="\033[0;36m"; RST="\033[0m"; BLD="\033[1m"
PASS=0; WARN=0; FAIL=0
pass() { ((PASS++)); echo -e "  ${GRN}✅ PASS${RST}  $*"; }
warn() { ((WARN++)); echo -e "  ${YLW}⚠️  WARN${RST}  $*"; }
fail() { ((FAIL++)); echo -e "  ${RED}❌ FAIL${RST}  $*"; }
info() { echo -e "  ${CYN}ℹ️  $*${RST}"; }

echo -e "${BLD}${CYN}━━━ ☤ Hermes Agent Doctor ━━━${RST}"
echo ""

echo -e "${BLD}[1/4] Hermes Agent${RST}"
if [ -d "$HOME/hermes-agent/.git" ]; then
    pass "Repository present"
    if [ -d "venv" ] && [ -f "venv/bin/activate" ]; then
        pass "Virtual environment present"
        PY_VER=$(python --version 2>&1 | grep -oP "\d+\.\d+")
        PY_MIN=$(echo "$PY_VER" | cut -d. -f2)
        if [ "$PY_MIN" -ge 11 ] && [ "$PY_MIN" -le 13 ]; then
            pass "Python $PY_VER (compatible)"
        else
            fail "Python $PY_VER — requires 3.11-3.13. Reinstall hermes-agent."
        fi
    else
        fail "venv missing"
    fi
    if hermes --version >/dev/null 2>&1; then
        pass "hermes command works"
    else
        fail "hermes command broken — run: hermes setup"
    fi
else
    fail "Hermes Agent not installed"
fi

echo ""
echo -e "${BLD}[2/4] API Keys${RST}"
KEY_FOUND=false
if [ -n "${GOOGLE_API_KEY:-}" ]; then
    pass "GOOGLE_API_KEY set (${#GOOGLE_API_KEY} chars)"
    [[ "$GOOGLE_API_KEY" =~ ^AIza ]] && pass "Format valid (starts with AIza)" || warn "Does not start with AIza"
    KEY_FOUND=true
fi
if [ -n "${GEMINI_API_KEY:-}" ]; then
    pass "GEMINI_API_KEY set (${#GEMINI_API_KEY} chars)"
    KEY_FOUND=true
fi
if [ -n "${OPENAI_API_KEY:-}" ]; then
    pass "OPENAI_API_KEY set (${#OPENAI_API_KEY} chars)"
    [[ "$OPENAI_API_KEY" =~ ^sk- ]] && pass "Format valid (starts with sk-)" || warn "Does not start with sk-"
    KEY_FOUND=true
fi
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    pass "ANTHROPIC_API_KEY set (${#ANTHROPIC_API_KEY} chars)"
    [[ "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]] && pass "Format valid (starts with sk-ant-)" || warn "Does not start with sk-ant-"
    KEY_FOUND=true
fi
if [ "$KEY_FOUND" = false ]; then
    fail "No API keys found!"
    info "Set in ~/.bashrc:"
    info "  export GOOGLE_API_KEY=\"your-key\""
    info "  Then: source ~/.bashrc"
fi

echo ""
echo -e "${BLD}[3/4] Connectivity${RST}"
curl -s --max-time 10 https://generativelanguage.googleapis.com >/dev/null 2>&1 && pass "Google AI API reachable" || warn "Google AI API unreachable"
curl -s --max-time 10 https://api.openai.com >/dev/null 2>&1 && pass "OpenAI API reachable" || warn "OpenAI API unreachable"
curl -s --max-time 10 https://api.anthropic.com >/dev/null 2>&1 && pass "Anthropic API reachable" || warn "Anthropic API unreachable"

echo ""
echo -e "${BLD}[4/4] Telegram${RST}"
if [ -n "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${HERMES_TELEGRAM_CHAT_ID:-}" ]; then
    pass "Telegram configured"
    TG=$(curl -s --max-time 10 "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null)
    if echo "$TG" | grep -q "\"ok\":true"; then
        BOT=$(echo "$TG" | grep -oP "\"username\":\"[^\"]*\"" | cut -d"\"" -f4)
        pass "Bot @${BOT} reachable"
    else
        warn "Bot token may be invalid"
    fi
else
    info "Telegram not configured (optional)"
fi

echo ""
echo -e "${BLD}${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "  Results: ${GRN}${PASS} passed${RST}  ${YLW}${WARN} warnings${RST}  ${RED}${FAIL} failed${RST}"
echo -e "${BLD}${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
if [ "$FAIL" -gt 0 ]; then
    echo -e "  ${RED}Fix the issues above and run again.${RST}"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo -e "  ${YLW}Some warnings — check items above.${RST}"
else
    echo -e "  ${GRN}All good! Run ${CYN}hermes gateway${GRN} to start.${RST}"
fi
exit 0
' -- "$@"
HERMES_DOCTOR
chmod +x "$PREFIX/bin/hermes-doctor"
ok "Created $PREFIX/bin/hermes-doctor"

# ──────────────────────────────────────────────
# [Improvement #6] Install hermes-update (refreshes launchers + Python package)
# ──────────────────────────────────────────────
cat > "$PREFIX/bin/hermes-update" << 'HERMES_UPDATE'
#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent updater — updates both Termux launchers AND Python package
# Usage: hermes-update [--edge]
#
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; RST='\033[0m'

REPO="fbscotta369/Hermes-Agent-On-Android"
RAW="https://raw.githubusercontent.com/${REPO}/main/scripts"

echo -e "${CYN}━━━ Updating Hermes Agent ━━━${RST}"

# Refresh Termux launchers from GitHub
echo -e "${YLW}  → Refreshing Termux launchers...${RST}"
for cmd in hermes hermes-setup hermes-gateway hermes-doctor hermes-update; do
    if curl -sf "${RAW}/${cmd}" -o "$PREFIX/bin/${cmd}" 2>/dev/null; then
        chmod +x "$PREFIX/bin/${cmd}"
        echo -e "  ${GRN}✓${RST} ${cmd}"
    else
        echo -e "  ${YLW}⚠${RST} ${cmd} — download failed, keeping current"
    fi
done

# Update Hermes Agent inside Ubuntu
if [ "${1:-}" = "--edge" ]; then
    echo -e "${YLW}  → Updating Hermes Agent (edge)...${RST}"
    exec proot-distro login ubuntu -- bash -c '
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd "$HOME/hermes-agent"
echo "  → Fetching latest code..."
git fetch origin && git reset --hard origin/main
source venv/bin/activate
uv pip install -e . >/dev/null 2>&1
echo -e "\n✅ Hermes Agent updated to latest main!"
'
else
    echo -e "${YLW}  → Updating Hermes Agent (stable)...${RST}"
    exec proot-distro login ubuntu -- bash -c '
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd "$HOME/hermes-agent"
echo "  → Fetching tags..."
git fetch --tags origin
LATEST_TAG=$(git tag --sort=-version:refname | head -1)
echo "  → Latest tag: $LATEST_TAG"
git checkout "$LATEST_TAG"
source venv/bin/activate
uv pip install -e . >/dev/null 2>&1
echo -e "\n✅ Hermes Agent updated to $LATEST_TAG!"
'
fi
HERMES_UPDATE
chmod +x "$PREFIX/bin/hermes-update"
ok "Created $PREFIX/bin/hermes-update"

# ──────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────
echo ""
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}     ✅  Hermes Agent installed successfully!${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

VERSION_DISPLAY="stable ($HERMES_TAG)"
if [ "$USE_EDGE" = "true" ]; then
    VERSION_DISPLAY="edge (main branch)"
fi
echo -e "  ${GRN}Version:${RST}  $VERSION_DISPLAY"
echo ""

echo -e "  ${GRN}Quick Start (no more 4-step ritual):${RST}"
echo -e "  ${CYN}  hermes setup${RST}     First-time configuration"
echo -e "  ${CYN}  hermes${RST}           Start the agent"
echo -e "  ${CYN}  hermes gateway${RST}   Start the gateway"
echo -e "  ${CYN}  hermes-update${RST}    Update to the latest version"
echo ""

# Refresh bash command cache so 'hermes' works immediately
hash -r 2>/dev/null || true

echo -e "  ${YLW}Tip:${RST} Type ${CYN}hermes${RST} right now — it's ready!"
echo -e "  ${YLW}Tip:${RST} If you restart Termux later, just type ${CYN}hermes${RST} — no extra steps needed."
echo ""

echo -e "  ${GRN}💡 Need help?${RST} https://github.com/fbscotta369/Hermes-Agent-On-Android"
echo ""
