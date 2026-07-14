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

# [Improvement #1] Fixed Ubuntu detection (original grep -q | grep pipe was broken)
info "Checking Ubuntu installation..."
if proot-distro list 2>/dev/null | grep -q "ubuntu.*Installed: yes"; then
    ok "Ubuntu is already installed"
else
    info "Installing Ubuntu (this may take a few minutes)..."
    if ! proot-distro install ubuntu; then
        fail "Failed to install Ubuntu"
    fi
    ok "Ubuntu installed"
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
    python3 python3-pip python3-venv python3-dev python-is-python3 \
    git curl wget build-essential \
    nodejs npm \
    libffi-dev libssl-dev pkg-config \
    ca-certificates >/dev/null 2>&1

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

# --- Python virtual environment ---
echo "  → Setting up Python virtual environment..."
rm -rf venv
python3 -m venv venv
source venv/bin/activate

echo "  → Upgrading pip..."
python3 -m pip install --upgrade pip setuptools wheel >/dev/null 2>&1

echo "  → Installing Hermes Agent (this can take 5-10 minutes)..."
if ! python3 -m pip install -e ".[all]" >/dev/null 2>&1; then
    echo "  ⚠️  Full extras install failed, trying base install..."
    python3 -m pip install -e "."
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

# --- hermes-gateway launcher ---
cat > "$PREFIX/bin/hermes-gateway" << 'HERMES_GATEWAY'
#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent gateway launcher
# Usage: hermes-gateway
#
exec proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" && source venv/bin/activate && exec hermes gateway "$@"
' -- "$@"
HERMES_GATEWAY
chmod +x "$PREFIX/bin/hermes-gateway"
ok "Created $PREFIX/bin/hermes-gateway"

# ──────────────────────────────────────────────
# [Improvement #6] Install hermes-update
# ──────────────────────────────────────────────
cat > "$PREFIX/bin/hermes-update" << 'HERMES_UPDATE'
#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent updater
# Usage: hermes-update [--edge]
#
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; RST='\033[0m'

echo -e "${CYN}━━━ Updating Hermes Agent ━━━${RST}"

if [ "${1:-}" = "--edge" ]; then
    echo -e "${YLW}  → Tracking main branch (edge)${RST}"
    exec proot-distro login ubuntu -- bash -c '
set -euo pipefail
cd "$HOME/hermes-agent"
echo "  → Fetching latest code..."
git fetch origin
git reset --hard origin/main
source venv/bin/activate
echo "  → Reinstalling..."
pip install -e . >/dev/null 2>&1
echo -e "\n✅ Hermes Agent updated to latest main!"
echo "   Run: hermes"
'
else
    echo -e "${YLW}  → Updating to latest stable tag...${RST}"
    exec proot-distro login ubuntu -- bash -c '
set -euo pipefail
cd "$HOME/hermes-agent"
echo "  → Fetching tags..."
git fetch --tags origin
LATEST_TAG=$(git tag --sort=-version:refname | head -1)
echo "  → Latest tag: $LATEST_TAG"
git checkout "$LATEST_TAG"
source venv/bin/activate
pip install -e . >/dev/null 2>&1
echo -e "\n✅ Hermes Agent updated to $LATEST_TAG!"
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
fi
echo -e "  ${GRN}Version:${RST}  $VERSION_DISPLAY"
echo ""

echo -e "  ${GRN}Quick Start (no more 4-step ritual):${RST}"
echo -e "  ${CYN}  hermes setup${RST}     First-time configuration"
echo -e "  ${CYN}  hermes${RST}           Start the agent"
echo -e "  ${CYN}  hermes gateway${RST}   Start the gateway"
echo -e "  ${CYN}  hermes-update${RST}    Update to the latest version"
echo ""

echo -e "  ${YLW}Pro-tip:${RST} Just close and reopen Termux, then type ${CYN}hermes${RST}"
echo ""

echo -e "  ${GRN}💡 Need help?${RST} https://github.com/fbscotta369/Hermes-Agent-On-Android"
echo ""
