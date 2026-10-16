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
#   curl -fsSL .../nous_agent.sh | bash -s -- --tag v2026.9.7
#   curl -fsSL .../nous_agent.sh | bash -s -- --latest
#
set -euo pipefail

# ──────────────────────────────────────────────
# Load libraries
# ──────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/colors.sh
. "$SCRIPT_DIR/scripts/lib/colors.sh"
# shellcheck source=scripts/lib/utils.sh
. "$SCRIPT_DIR/scripts/lib/utils.sh"
# shellcheck source=scripts/lib/telegram.sh
. "$SCRIPT_DIR/scripts/lib/telegram.sh"

# ──────────────────────────────────────────────
# Configuration (overridable via flags)
# ──────────────────────────────────────────────
HERMES_REPO="https://github.com/NousResearch/hermes-agent.git"
HERMES_TAG="v2026.9.7"
USE_EDGE=false
USE_LATEST=false
CUSTOM_TAG=""

# Known checksums for supply chain security
# Update these when versions change
NOUS_AGENT_SHA256="REPLACE_WITH_ACTUAL_SHA256_OF_NOUS_AGENT_SH"
UV_INSTALLER_SHA256="REPLACE_WITH_ACTUAL_SHA256_OF_UV_INSTALLER"

# ──────────────────────────────────────────────
# Parse arguments
# ──────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --edge)     
            USE_EDGE=true 
            ;;
        --stable)   
            USE_EDGE=false 
            USE_LATEST=false
            ;;
        --latest)   
            USE_LATEST=true
            USE_EDGE=false
            ;;
        --tag=*)    
            CUSTOM_TAG="${arg#*=}"
            USE_EDGE=false
            USE_LATEST=false
            ;;
        --help|-h)
            echo "Usage: curl -fsSL .../nous_agent.sh | bash [-- <flags>]"
            echo ""
            echo "Flags:"
            echo "  --edge          Track Hermes Agent main branch (latest, potentially unstable)"
            echo "  --stable        Use the pinned stable release (default)"
            echo "  --latest        Auto-discover and use latest stable release tag"
            echo "  --tag=vX.Y.Z    Pin to a specific release tag"
            echo "  --help, -h      Show this help"
            exit 0
            ;;
    esac
done

if [ -n "$CUSTOM_TAG" ]; then
    HERMES_TAG="$CUSTOM_TAG"
    USE_EDGE=false
    USE_LATEST=false
fi

# ──────────────────────────────────────────────
# Auto-discover latest tag if --latest
# ──────────────────────────────────────────────
if [ "$USE_LATEST" = true ]; then
    step "Discovering latest Hermes Agent release..."
    LATEST_TAG=$(get_latest_hermes_tag)
    if [ -n "$LATEST_TAG" ]; then
        HERMES_TAG="$LATEST_TAG"
        ok "Latest stable release: $HERMES_TAG"
    else
        warn "Could not discover latest tag, using pinned: $HERMES_TAG"
    fi
fi

# ──────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────
cleanup() {
    [ -n "${INNER_SCRIPT:-}" ] && rm -f "$INNER_SCRIPT"
    release_awake
}
trap cleanup EXIT

# ──────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────
show_banner "HERMES AGENT FOR ANDROID" "AIIA-Labs | https://aiia-labs.com"

# ──────────────────────────────────────────────
# Pre-flight environment checks
# ──────────────────────────────────────────────
step "Pre-flight checks"

# --- Android version ---
ANDROID_SDK=$(get_android_sdk)
if [ "$ANDROID_SDK" -eq 0 ]; then
    warn "Could not detect Android API level. Not in Termux? Continuing anyway..."
elif [ "$ANDROID_SDK" -lt 30 ]; then
    fail "Android 11+ (API 30+) required. Found API ${ANDROID_SDK}."
else
    ok "Android API ${ANDROID_SDK}"
fi

# --- Storage space (at least 3 GB free) ---
AVAIL_MB=$(get_storage_mb)
if [ "$AVAIL_MB" -gt 0 ] && [ "$AVAIL_MB" -lt 3000 ]; then
    fail "At least 3 GB free storage required. Found ~$((AVAIL_MB / 1024)) GB."
elif [ "$AVAIL_MB" -ge 3000 ]; then
    ok "Storage: ~$((AVAIL_MB / 1024)) GB free"
else
    warn "Could not check storage space"
fi

# --- Internet connectivity ---
if ! check_internet; then
    fail "No internet connectivity detected. Check your connection."
fi
ok "Internet connected"

# --- Keep device awake ---
keep_awake

# ──────────────────────────────────────────────
# Install proot-distro + Ubuntu
# ──────────────────────────────────────────────
step "Setting up proot-distro environment"

info "Installing / updating proot-distro..."
if ! pkg install proot-distro -y 2>&1; then
    fail "Failed to install proot-distro"
fi
ok "proot-distro ready"

# Ubuntu detection — filesystem check is the only reliable method
info "Checking Ubuntu installation..."

if is_ubuntu_installed; then
    ok "Ubuntu is already installed"
else
    info "Installing Ubuntu (this may take a few minutes)..."
    start_spinner "Installing Ubuntu..."
    OUTPUT=$(proot-distro install ubuntu 2>&1) || {
        stop_spinner
        if echo "$OUTPUT" | grep -qi "already exists"; then
            warn "Ubuntu container already exists. Continuing..."
        else
            fail "Failed to install Ubuntu: $OUTPUT"
        fi
    }
    stop_spinner ok "Ubuntu ready"
fi

# ──────────────────────────────────────────────
# Write inner install script to temp file
# ──────────────────────────────────────────────
step "Installing Hermes Agent inside Ubuntu"

INNER_SCRIPT=$(mktemp)

cat > "$INNER_SCRIPT" << INNER_EOF
#!/bin/bash
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
apt-get install -y -o Dpkg::Options::="--force-confold" \\
    git curl wget build-essential \\
    nodejs npm \\
    libffi-dev libssl-dev pkg-config \\
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
        git clone --depth 1 --recurse-submodules --shallow-submodules \\
            "\$HERMES_REPO" "\$REPO_DIR"
    else
        echo "  → Using stable release: \$HERMES_TAG"
        git clone --depth 1 --branch "\$HERMES_TAG" --recurse-submodules --shallow-submodules \\
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
# Install Termux-level launchers
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
# Requires environment variables (set in ~/.bashrc):
#   HERMES_TELEGRAM_BOT_TOKEN   — Telegram bot token from @BotFather
#   HERMES_TELEGRAM_CHAT_ID     — Your Telegram chat ID
#
# If env vars are not set, the gateway runs without notifications.
#
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; RST='\033[0m'

# ── Telegram notification helper ──
send_telegram() {
    [ -z "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${HERMES_TELEGRAM_CHAT_ID:-}" ] && return 0
    curl -s -X POST "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${HERMES_TELEGRAM_CHAT_ID}" \
        -d text="$1" \
        --max-time 10 >/dev/null 2>&1 || true
}

# ── Send offline notification on exit (Ctrl+C, kill, crash) ──
OFFLINE_SENT=false
send_offline() {
    if [ "$OFFLINE_SENT" = "false" ]; then
        OFFLINE_SENT=true
        send_telegram "Hermes Agent Gateway offline :-("
    fi
}
trap send_offline EXIT

# ── Pre-flight check: is an API key configured? ──
check_api_key() {
    if [ -z "${GOOGLE_API_KEY:-}" ] && [ -z "${GEMINI_API_KEY:-}" ] && \
       [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
        echo -e "${RED}  ❌  No API key found in environment!${RST}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
        echo ""
        echo -e "  ${YLW}Set one of these in ~/.bashrc:${RST}"
        echo -e "    export ${CYN}GOOGLE_API_KEY${RST}=\"your-gemini-key\""
        echo -e "    export ${CYN}OPENAI_API_KEY${RST}=\"your-openai-key\""
        echo -e "    export ${CYN}ANTHROPIC_API_KEY${RST}=\"your-claude-key\""
        echo ""
        echo -e "  Then run: ${CYN}source ~/.bashrc${RST}"
        echo -e "  Or run ${CYN}hermes-doctor${RST} for full diagnostics."
        echo ""
        send_telegram "Hermes Agent Gateway failed: No API key configured!"
        exit 1
    fi
}

check_api_key

# ── Show which provider is configured ──
if [ -n "${GOOGLE_API_KEY:-}" ] || [ -n "${GEMINI_API_KEY:-}" ]; then
    echo -e "${CYN}  Provider: Google Gemini${RST}"
elif [ -n "${OPENAI_API_KEY:-}" ]; then
    echo -e "${CYN}  Provider: OpenAI${RST}"
elif [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo -e "${CYN}  Provider: Anthropic${RST}"
fi

# ── Send online notification on start ──
send_telegram "Hermes Agent Gateway online ;-)"

# ── Start the gateway (no exec — trap needs the process to return) ──
GATEWAY_EXIT=0
proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" && source venv/bin/activate && exec hermes gateway "$@"
' -- "$@" || GATEWAY_EXIT=$?

# ── If gateway failed, show diagnostic help ──
if [ "$GATEWAY_EXIT" -ne 0 ]; then
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
    echo -e "${RED}  ⚠️  Hermes Agent Gateway exited with errors${RST}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
    echo ""
    echo -e "  ${YLW}Common causes:${RST}"
    echo -e "    1. ${CYN}API key invalid or expired${RST}"
    echo -e "       → Re-generate at your provider's dashboard"
    echo -e "       → Run ${CYN}hermes setup${RST} to reconfigure"
    echo ""
    echo -e "    2. ${CYN}API key not set${RST}"
    echo -e "       → Run ${CYN}hermes-doctor${RST} to check configuration"
    echo ""
    echo -e "    3. ${CYN}Provider API down or rate-limited${RST}"
    echo -e "       → Check status: try again in a few minutes"
    echo ""
    echo -e "  ${YLW}For detailed logs:${RST}"
    echo -e "    proot-distro login ubuntu"
    echo -e "    cd ~/hermes-agent && source venv/bin/activate"
    echo -e "    hermes gateway --log-level debug"
    echo ""
    echo -e "  ${YLW}Or run diagnostics:${RST}"
    echo -e "    ${CYN}hermes-doctor${RST}"
    echo ""

    send_telegram "Hermes Agent Gateway failed (exit code $GATEWAY_EXIT). Check: hermes-doctor"
fi
HERMES_GATEWAY
chmod +x "$PREFIX/bin/hermes-gateway"
ok "Created $PREFIX/bin/hermes-gateway"

# --- hermes-doctor diagnostic launcher ---
cat > "$PREFIX/bin/hermes-doctor" << 'HERMES_DOCTOR'
#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent Doctor — Diagnose and fix common issues
# Usage: hermes-doctor
#
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; RST='\033[0m'; BLD='\033[1m'

PASS=0; WARN=0; FAIL=0

pass() { ((PASS++)); echo -e "  ${GRN}✅ PASS${RST}  $*"; }
warn() { ((WARN++)); echo -e "  ${YLW}⚠️  WARN${RST}  $*"; }
fail() { ((FAIL++)); echo -e "  ${RED}❌ FAIL${RST}  $*"; }
info() { echo -e "  ${CYN}ℹ️  $*${RST}"; }

echo -e "${BLD}${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${BLD}${CYN}     ☤  Hermes Agent Doctor  ☤${RST}"
echo -e "${BLD}${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

# ═══════════════════════════════════════════
# 1. Termux environment
# ═══════════════════════════════════════════
echo -e "${BLD}[1/6] Termux Environment${RST}"

ANDROID_SDK=$(getprop ro.build.version.sdk 2>/dev/null || echo 0)
if [ "$ANDROID_SDK" -eq 0 ]; then
    warn "Could not detect Android version"
elif [ "$ANDROID_SDK" -lt 30 ]; then
    fail "Android 11+ required (API 30+). Found API $ANDROID_SDK"
else
    pass "Android API $ANDROID_SDK"
fi

AVAIL_MB=$(df -m /data 2>/dev/null | awk 'NR==2{print $4}' || echo 0)
if [ "$AVAIL_MB" -gt 3000 ]; then
    pass "Storage: $((AVAIL_MB / 1024)) GB free"
elif [ "$AVAIL_MB" -gt 0 ]; then
    warn "Storage: $((AVAIL_MB / 1024)) GB free (3 GB+ recommended)"
else
    warn "Could not check storage"
fi

if command -v proot-distro &>/dev/null; then
    pass "proot-distro installed"
else
    fail "proot-distro not found — run: pkg install proot-distro"
fi

# ═══════════════════════════════════════════
# 2. Internet connectivity
# ═══════════════════════════════════════════
echo ""
echo -e "${BLD}[2/6] Internet Connectivity${RST}"

if curl -s --max-time 10 https://github.com >/dev/null 2>&1; then
    pass "GitHub reachable"
else
    fail "GitHub unreachable — check your internet connection"
fi

if curl -s --max-time 10 https://generativelanguage.googleapis.com >/dev/null 2>&1; then
    pass "Google AI API reachable"
elif curl -s --max-time 10 https://api.openai.com >/dev/null 2>&1; then
    pass "OpenAI API reachable"
elif curl -s --max-time 10 https://api.anthropic.com >/dev/null 2>&1; then
    pass "Anthropic API reachable"
else
    warn "No AI provider API endpoints reachable"
fi

# ═══════════════════════════════════════════
# 3. Hermes Agent installation (inside Ubuntu)
# ═══════════════════════════════════════════
echo ""
echo -e "${BLD}[3/6] Hermes Agent Installation${RST}"

HERMES_CHECK=$(proot-distro login ubuntu -- bash -c '
    set -e
    if [ -d "$HOME/hermes-agent/.git" ]; then
        echo "REPO_OK"
        cd "$HOME/hermes-agent"
        if [ -d "venv" ] && [ -f "venv/bin/activate" ]; then
            echo "VENV_OK"
            source venv/bin/activate
            python --version 2>&1 | cut -d" " -f2
        else
            echo "VENV_MISSING"
        fi
    else
        echo "REPO_MISSING"
    fi
' 2>/dev/null || echo "PROOT_FAILED")

if echo "$HERMES_CHECK" | grep -q "PROOT_FAILED"; then
    fail "Cannot access Ubuntu — proot-distro may be broken"
elif echo "$HERMES_CHECK" | grep -q "REPO_MISSING"; then
    fail "Hermes Agent not installed — run: curl -fsSL .../nous_agent.sh | bash"
elif echo "$HERMES_CHECK" | grep -q "VENV_MISSING"; then
    fail "Python venv missing — run: hermes setup"
else
    pass "Hermes Agent repository present"
    pass "Python venv present"
    PYTHON_VER=$(echo "$HERMES_CHECK" | grep -E "^[0-9]+\.[0-9]+" | head -1)
    if [ -n "$PYTHON_VER" ]; then
        PY_MAJOR=$(echo "$PYTHON_VER" | cut -d. -f1)
        PY_MINOR=$(echo "$PYTHON_VER" | cut -d. -f2)
        if [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -ge 11 ] && [ "$PY_MINOR" -le 13 ]; then
            pass "Python $PYTHON_VER (compatible)"
        elif [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -ge 14 ]; then
            fail "Python $PYTHON_VER is too new (requires <3.14). Run the installer again to fix."
        else
            warn "Python $PYTHON_VER — may have compatibility issues"
        fi
    fi
fi

# Check hermes command
if proot-distro login ubuntu -- bash -c 'cd ~/hermes-agent && source venv/bin/activate && hermes --version' >/dev/null 2>&1; then
    pass "hermes command works"
else
    fail "hermes command broken — run: hermes setup"
fi

# ═══════════════════════════════════════════
# 4. Termux launcher commands
# ═══════════════════════════════════════════
echo ""
echo -e "${BLD}[4/6] Termux Launchers${RST}"

for cmd in hermes hermes-setup hermes-update hermes-gateway hermes-doctor; do
    if [ -x "$PREFIX/bin/$cmd" ]; then
        pass "$cmd command installed"
    else
        fail "$cmd command missing — re-run the installer"
    fi
done

# ═══════════════════════════════════════════
# 5. API Key configuration
# ═══════════════════════════════════════════
echo ""
echo -e "${BLD}[5/6] API Key Configuration${RST}"

KEY_FOUND=false

if [ -n "${GOOGLE_API_KEY:-}" ]; then
    pass "GOOGLE_API_KEY is set (${#GOOGLE_API_KEY} chars)"
    KEY_FOUND=true
    if [[ "$GOOGLE_API_KEY" =~ ^AIza ]]; then
        pass "GOOGLE_API_KEY format looks valid (starts with AIza)"
    else
        warn "GOOGLE_API_KEY doesn't start with 'AIza' — may be invalid"
    fi
fi

if [ -n "${GEMINI_API_KEY:-}" ]; then
    pass "GEMINI_API_KEY is set (${#GEMINI_API_KEY} chars)"
    KEY_FOUND=true
fi

if [ -n "${OPENAI_API_KEY:-}" ]; then
    pass "OPENAI_API_KEY is set (${#OPENAI_API_KEY} chars)"
    KEY_FOUND=true
    if [[ "$OPENAI_API_KEY" =~ ^sk- ]]; then
        pass "OPENAI_API_KEY format looks valid (starts with sk-)"
    else
        warn "OPENAI_API_KEY doesn't start with 'sk-' — may be invalid"
    fi
fi

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    pass "ANTHROPIC_API_KEY is set (${#ANTHROPIC_API_KEY} chars)"
    KEY_FOUND=true
    if [[ "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]]; then
        pass "ANTHROPIC_API_KEY format looks valid (starts with sk-ant-)"
    else
        warn "ANTHROPIC_API_KEY doesn't start with 'sk-ant-' — may be invalid"
    fi
fi

if [ "$KEY_FOUND" = false ]; then
    fail "No API keys found in environment!"
    info "Set your key in ~/.bashrc:"
    info "  export GOOGLE_API_KEY=\"your-key\""
    info "  export OPENAI_API_KEY=\"your-key\""
    info "  export ANTHROPIC_API_KEY=\"your-key\""
    info "Then run: source ~/.bashrc"
fi

# ═══════════════════════════════════════════
# 6. Telegram notifications (optional)
# ═══════════════════════════════════════════
echo ""
echo -e "${BLD}[6/6] Telegram Notifications (optional)${RST}"

if [ -n "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${HERMES_TELEGRAM_CHAT_ID:-}" ]; then
    pass "Telegram notifications configured"
    TG_RESULT=$(curl -s --max-time 10 "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null)
    if echo "$TG_RESULT" | grep -q '"ok":true'; then
        BOT_NAME=$(echo "$TG_RESULT" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        pass "Telegram bot @${BOT_NAME} is reachable"
    else
        warn "Telegram bot token may be invalid — check @BotFather"
    fi
elif [ -n "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] || [ -n "${HERMES_TELEGRAM_CHAT_ID:-}" ]; then
    warn "Telegram partially configured — need both BOT_TOKEN and CHAT_ID"
else
    info "Telegram notifications not configured (optional)"
    info "See README for setup instructions"
fi

# ═══════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════
echo ""
echo -e "${BLD}${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${BLD}  Results: ${GRN}${PASS} passed${RST}  ${YLW}${WARN} warnings${RST}  ${RED}${FAIL} failed${RST}"
echo -e "${BLD}${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo -e "  ${RED}Fix the issues above and run ${CYN}hermes-doctor${RED} again.${RST}"
    echo ""
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo ""
    echo -e "  ${YLW}Some warnings — check the items above.${RST}"
    echo ""
    exit 0
else
    echo ""
    echo -e "  ${GRN}Everything looks good! Run ${CYN}hermes gateway${GRN} to start.${RST}"
    echo ""
    exit 0
fi
HERMES_DOCTOR
chmod +x "$PREFIX/bin/hermes-doctor"
ok "Created $PREFIX/bin/hermes-doctor"

# ──────────────────────────────────────────────
# Install hermes-update (refreshes launchers + Python package)
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

# ── Step 1: Refresh Termux launchers from GitHub ──
echo -e "${YLW}  → Refreshing Termux launchers...${RST}"

for cmd in hermes hermes-setup hermes-gateway hermes-doctor hermes-update; do
    if curl -sf "${RAW}/${cmd}" -o "$PREFIX/bin/${cmd}" 2>/dev/null; then
        chmod +x "$PREFIX/bin/${cmd}"
        echo -e "  ${GRN}✓${RST} ${cmd}"
    else
        echo -e "  ${YLW}⚠${RST} ${cmd} — download failed, keeping current version"
    fi
done

# ── Step 2: Update Hermes Agent inside Ubuntu ──
if [ "${1:-}" = "--edge" ]; then
    echo -e "${YLW}  → Updating Hermes Agent (edge — main branch)...${RST}"
    proot-distro login ubuntu -- bash -c '
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd "$HOME/hermes-agent"
OLD_VERSION=$(git describe --tags --always 2>/dev/null || echo "unknown")
echo "  → Current version: $OLD_VERSION"
echo "  → Fetching latest code..."
git fetch origin
git reset --hard origin/main
source venv/bin/activate
echo "  → Reinstalling..."
uv pip install -e . >/dev/null 2>&1
NEW_VERSION=$(git describe --tags --always 2>/dev/null || echo "unknown")
echo -e "\n✅ Hermes Agent updated to latest main!"
echo "   Version: $OLD_VERSION → $NEW_VERSION"
echo "   Run: hermes"
'
else
    echo -e "${YLW}  → Updating Hermes Agent (stable — latest tag)...${RST}"
    proot-distro login ubuntu -- bash -c '
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd "$HOME/hermes-agent"
OLD_VERSION=$(git describe --tags --always 2>/dev/null || echo "unknown")
echo "  → Current version: $OLD_VERSION"
echo "  → Fetching tags..."
git fetch --tags origin
LATEST_TAG=$(git tag --sort=-version:refname | head -1)
echo "  → Latest tag: $LATEST_TAG"
git checkout "$LATEST_TAG"
source venv/bin/activate
echo "  → Reinstalling..."
uv pip install -e . >/dev/null 2>&1
echo -e "\n✅ Hermes Agent updated to $LATEST_TAG!"
echo "   Version: $OLD_VERSION → $LATEST_TAG"
echo "   Run: hermes"
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
elif [ "$USE_LATEST" = "true" ]; then
    VERSION_DISPLAY="latest ($HERMES_TAG)"
fi
echo -e "  ${GRN}Version:${RST}  $VERSION_DISPLAY"
echo ""

echo -e "  ${GRN}Quick Start (no more 4-step ritual):${RST}"
echo -e "  ${CYN}  hermes setup${RST}     First-time configuration"
echo -e "  ${CYN}  hermes${RST}           Start the agent"
echo -e "  ${CYN}  hermes gateway${RST}   Start the gateway"
echo -e "  ${CYN}  hermes-doctor${RST}    Run diagnostics"
echo -e "  ${CYN}  hermes-update${RST}    Update to the latest version"
echo -e "  ${CYN}  hermes-update --edge${RST}  Update to main branch"
echo ""

# Refresh bash command cache so 'hermes' works immediately
hash -r 2>/dev/null || true

echo -e "  ${YLW}Tip:${RST} Type ${CYN}hermes${RST} right now — it's ready!"
echo -e "  ${YLW}Tip:${RST} If you restart Termux later, just type ${CYN}hermes${RST} — no extra steps needed."
echo ""

echo -e "  ${GRN}💡 Need help?${RST} https://github.com/fbscotta369/Hermes-Agent-On-Android"
echo ""