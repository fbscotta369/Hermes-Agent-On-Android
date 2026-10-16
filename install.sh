#!/bin/bash
#
# Hermes Agent — Direct Termux Install (Alternative)
# Repository: https://github.com/fbscotta369/Hermes-Agent-On-Android
#
# This installs Hermes Agent directly in Termux (without proot-distro/Ubuntu).
# NOTE: The recommended approach is nous_agent.sh (proot-based for better compat).
# Use this only if you know you need direct Termux Python.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- --latest
#
set -euo pipefail

# ──────────────────────────────────────────────
# Load libraries (works from a clone OR piped via curl)
# ──────────────────────────────────────────────
_HERMES_LIB_TMP=""
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "$(dirname "${BASH_SOURCE[0]}")/scripts/lib/colors.sh" ]]; then
    LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/lib"
elif [[ -f "scripts/lib/colors.sh" ]]; then
    LIB_DIR="$(cd scripts/lib && pwd)"
else
    _HERMES_LIB_TMP="$(mktemp -d /tmp/hermes-libs.XXXXXX)"
    LIB_DIR="$_HERMES_LIB_TMP"
    for _lib in colors utils telegram; do
        curl -fsSL "https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/scripts/lib/$_lib.sh" -o "$LIB_DIR/$_lib.sh"
    done
fi
# shellcheck source=scripts/lib/colors.sh
. "$LIB_DIR/colors.sh"
# shellcheck source=scripts/lib/utils.sh
. "$LIB_DIR/utils.sh"
# shellcheck source=scripts/lib/telegram.sh
. "$LIB_DIR/telegram.sh"

# ──────────────────────────────────────────────
# Parse arguments
# ──────────────────────────────────────────────
USE_LATEST=false
for arg in "$@"; do
    case "$arg" in
        --latest)
            USE_LATEST=true
            ;;
        --help|-h)
            echo "Usage: curl -fsSL .../install.sh | bash [-- <flags>]"
            echo ""
            echo "Flags:"
            echo "  --latest        Auto-discover and use latest stable release tag"
            echo "  --help, -h      Show this help"
            exit 0
            ;;
    esac
done

# ──────────────────────────────────────────────
# Auto-discover latest tag if --latest
# ──────────────────────────────────────────────
HERMES_TAG="v2026.9.7"
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
# Banner
# ──────────────────────────────────────────────
show_banner "HERMES AGENT — DIRECT TERMUX INSTALL" "AIIA-Labs | https://aiia-labs.com"

# ──────────────────────────────────────────────
# Pre-flight checks
# ──────────────────────────────────────────────
step "Pre-flight checks"

# Connectivity
if ! check_internet; then
    fail "No internet connectivity detected"
fi
ok "Internet connected"

# Storage
AVAIL_MB=$(get_storage_mb)
if [ "$AVAIL_MB" -gt 0 ] && [ "$AVAIL_MB" -lt 3000 ]; then
    fail "At least 3 GB free required. Found ~$((AVAIL_MB / 1024)) GB."
fi
ok "Storage: ~$((AVAIL_MB / 1024)) GB free"

# Fix apt prompts
export DEBIAN_FRONTEND=noninteractive

# Keep device awake
keep_awake

# ──────────────────────────────────────────────
# Install dependencies
# ──────────────────────────────────────────────
step "Installing dependencies"

start_spinner "Updating package lists..."
pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null || pkg update -y || true
stop_spinner ok "Package lists updated"

info "Installing uv (Python version manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
ok "uv ready: $(uv --version)"

start_spinner "Installing system dependencies..."
pkg install -y git clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg 2>/dev/null
stop_spinner ok "System dependencies installed"

# ──────────────────────────────────────────────
# Clone and install
# ──────────────────────────────────────────────
step "Installing Hermes Agent"

ok "Cloning Hermes Agent..."
rm -rf hermes-agent 2>/dev/null
git clone --recurse-submodules --depth 1 --branch "$HERMES_TAG" https://github.com/NousResearch/hermes-agent.git
cd hermes-agent

ok "Setting up Python virtual environment with compatible version..."
uv venv --python ">=3.11,<3.14" venv
source venv/bin/activate

export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk 2>/dev/null || echo 24)"

ok "Python version: $(python --version)"

ok "Upgrading pip..."
uv pip install --upgrade pip setuptools wheel

start_spinner "Installing Hermes Agent (5-10 min)..."
if ! uv pip install -e '.[termux]' -c constraints-termux.txt >/dev/null 2>&1; then
    stop_spinner warn "Termux extras install failed, trying base install..."
    uv pip install -e .
else
    stop_spinner ok "Hermes Agent installed"
fi

# Create global symlink
ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"
ok "Created $PREFIX/bin/hermes"

# ──────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────
echo ""
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}     ✅  Hermes Agent installed successfully!${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

VERSION_DISPLAY="stable ($HERMES_TAG)"
if [ "$USE_LATEST" = "true" ]; then
    VERSION_DISPLAY="latest ($HERMES_TAG)"
fi
echo -e "  ${GRN}Version:${RST}  $VERSION_DISPLAY"
echo ""
echo -e "  ${GRN}Run:${RST}"
echo -e "  ${CYN}  hermes setup${RST}     First-time configuration"
echo -e "  ${CYN}  hermes${RST}           Start the agent"
echo -e "  ${CYN}  hermes gateway${RST}   Start the gateway"
echo ""
echo -e "  ${YLW}Note:${RST} This is the direct Termux install. For better compatibility,"
echo -e "  use the proot-based installer: ${CYN}curl -fsSL .../nous_agent.sh | bash${RST}"
echo ""
echo -e "  ${GRN}💡 Need help?${RST} https://github.com/fbscotta369/Hermes-Agent-On-Android"
echo ""

# Release wake lock and temp libs on exit
cleanup_libs() { [[ -n "${_HERMES_LIB_TMP:-}" ]] && rm -rf "$_HERMES_LIB_TMP"; release_awake; }
trap cleanup_libs EXIT