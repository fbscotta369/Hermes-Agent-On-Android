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
#

set -euo pipefail

GRN='\033[0;32m'
CYN='\033[0;36m'
YEL='\033[0;33m'
RED='\033[0;31m'
RST='\033[0m'

step() { echo -e "${GRN}━━━ ${CYN}$*${RST}"; }
ok()   { echo -e "${GRN}  ✅ $*${RST}"; }
fail() { echo -e "${RED}  ❌ $*${RST}"; exit 1; }

clear
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}    ☤  Hermes Agent — Direct Termux Install${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

# ── Pre-flight checks ──
step "Pre-flight checks"

# Connectivity
if ! curl -s --max-time 10 https://github.com >/dev/null 2>&1; then
    fail "No internet connectivity detected"
fi
ok "Internet connected"

# Storage
AVAIL_MB=$(df -m /data 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)
if [ "$AVAIL_MB" -gt 0 ] && [ "$AVAIL_MB" -lt 3000 ]; then
    fail "At least 3 GB free required. Found ~$((AVAIL_MB / 1024)) GB."
fi
ok "Storage: ~$((AVAIL_MB / 1024)) GB free"

# Fix apt prompts
export DEBIAN_FRONTEND=noninteractive

# Keep device awake
termux-wake-lock 2>/dev/null || true

# ── Install dependencies ──
step "Installing dependencies"

ok "Updating package lists..."
pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null || pkg update -y || true

ok "Installing Python..."
pkg install -y python

# Patch Python sysconfig for psutil compatibility (Python 3.13 on Termux)
step "Patching Python sysconfig for psutil compatibility..."
_file="$(find $PREFIX/lib/python3.* -name "_sysconfigdata*.py" 2>/dev/null | head -1)"
if [ -f "$_file" ]; then
    cp "$_file" "$_file.backup"
    sed -i 's|-fno-openmp-implicit-rpath||g' "$_file"
    rm -rf $PREFIX/lib/python3.*/__pycache__
    ok "Python patched"
else
    echo -e "${YEL}  ⚠️  Python sysconfig not found, patches may be needed for psutil${RST}"
fi

ok "Installing other dependencies..."
pkg install -y git clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg

# ── Clone and install ──
step "Installing Hermes Agent"

ok "Cloning Hermes Agent..."
rm -rf hermes-agent 2>/dev/null
git clone --recurse-submodules --depth 1 https://github.com/NousResearch/hermes-agent.git
cd hermes-agent

ok "Setting up Python virtual environment..."
python -m venv venv
source venv/bin/activate

export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk 2>/dev/null || echo 24)"

ok "Upgrading pip..."
python -m pip install --upgrade pip setuptools wheel

ok "Installing Hermes Agent (this may take 5-10 minutes)..."
if ! python -m pip install -e '.[termux]' -c constraints-termux.txt; then
    echo -e "${YEL}  ⚠️  Termux extras install failed, trying base install...${RST}"
    python -m pip install -e .
fi

# Create global symlink
ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"
ok "Created $PREFIX/bin/hermes"

# ── Done ──
echo ""
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}     ✅  Hermes Agent installed successfully!${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""
echo -e "${GRN}  Run:${RST}"
echo -e "  ${CYN}  hermes setup${RST}     First-time configuration"
echo -e "  ${CYN}  hermes${RST}           Start the agent"
echo -e "  ${CYN}  hermes gateway${RST}   Start the gateway"
echo ""
