#!/bin/bash

# Hermes Agent - One-line installer for Termux (Android)
# Optimized by THEVOIDKERNEL

set -e

# Colors for output
CYN='\033[0;36m'
GRN='\033[0;32m'
RST='\033[0m'

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}                THEVOIDKERNEL"
echo -e "${CYN}=====================================================${RST}"

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}        🚀 Installing Hermes Agent on Termux..."
echo -e "${CYN}=====================================================${RST}"

echo "📦 Repository: https://github.com/AbuZar-Ansarii/Hermes-Agent-On-Android"

# 1. Update and install system dependencies
# We add python-psutil here to avoid the "platform android is not supported" pip error
pkg update && pkg upgrade -y
pkg install -y git python python-psutil clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg

# 2. Clone repository
# Using a fresh clone to ensure no local conflicts
if [ -d "hermes-agent" ]; then
    echo "Directory hermes-agent already exists. Updating..."
    cd hermes-agent && git pull && cd ..
else
    git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git
fi

cd hermes-agent

# 3. Setup Python virtual environment with SYSTEM SITE PACKAGES
# This allows the venv to use the 'psutil' we installed via pkg
echo "Setting up virtual environment..."
rm -rf venv # Clean old venv if exists
python -m venv venv --system-site-packages
source venv/bin/activate

# 4. Set Android environment variables
export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"

# 5. Upgrade pip and install
echo "Installing Hermes Agent dependencies..."
python -m pip install --upgrade pip setuptools wheel

# We use --no-build-isolation to prevent it from trying to compile psutil again
python -m pip install -e '.[termux]' -c constraints-termux.txt

# 6. Create global symlink
ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"

echo -e "${GRN}✅ Hermes Agent installed successfully!${RST}"
echo "-----------------------------------------------------"
echo "🔥 Run 'hermes setup' to configure your providers (Ollama/Gemini)"
echo "🌐 Run 'hermes gateway' to deploy your Telegram bot"
echo "📖 Type 'hermes --help' for more options"
echo "-----------------------------------------------------"
echo "💡 Need help? Visit: https://github.com/AbuZar-Ansarii/Hermes-Agent-On-Android"
echo ""
