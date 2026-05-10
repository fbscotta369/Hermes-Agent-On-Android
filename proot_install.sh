#!/bin/bash

# Hermes Agent - Error-Free Termux Installer
# Optimized for THEVOIDKERNEL (Rishikesh Build)

# 1. FORCE FIX BROKEN DPKG (Run this to clear the "EOF" error)
echo "🛠️ Repairing broken package database..."
export DEBIAN_FRONTEND=noninteractive
dpkg --configure -a --force-confdef --force-confold

# 2. Setup environment to bypass all future prompts
set -e
export DEBIAN_FRONTEND=noninteractive
APT_OPTS="-y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'"

# Colors
CYN='\033[0;36m'
GRN='\033[0;32m'
RST='\033[0m'

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}                THEVOIDKERNEL"
echo -e "${CYN}=====================================================${RST}"

# 3. Update with forced non-interactive flags
echo "📦 Updating system packages (Silently)..."
apt update $APT_OPTS
apt upgrade $APT_OPTS

# 4. Install Dependencies (Including pre-built psutil)
echo "📥 Installing core dependencies..."
apt install $APT_OPTS python python-psutil git clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg

# 5. Clone or Update Hermes
if [ -d "hermes-agent" ]; then
    echo "🔄 Existing installation found. Pulling latest code..."
    cd hermes-agent && git pull && cd ..
else
    echo "🌐 Cloning Hermes Agent..."
    git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git
fi

cd hermes-agent

# 6. Virtual Environment Setup (System-Linked)
echo "🐍 Setting up Python environment..."
rm -rf venv
python -m venv venv --system-site-packages
source venv/bin/activate

# 7. Install Python Requirements
export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"
python -m pip install --upgrade pip setuptools wheel
echo "🏗️ Installing Hermes packages..."
python -m pip install -e '.[termux]' -c constraints-termux.txt

# 8. Finalize Symlink
ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"

echo -e "${GRN}✅ SUCCESS: Hermes Agent is ready!${RST}"
echo "-----------------------------------------------------"
echo "👉 Run 'hermes setup' to begin."
echo "👉 Run 'hermes gateway' for Telegram."
echo "-----------------------------------------------------"
