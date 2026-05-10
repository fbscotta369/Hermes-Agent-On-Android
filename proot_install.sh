#!/data/data/com.termux/files/usr/bin/bash

set -e

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
RST='\033[0m'

clear

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}         HERMES AGENT TERMUX INSTALLER"
echo -e "${CYN}=====================================================${RST}"

echo -e "${YLW}Updating packages...${RST}"

pkg update -y
pkg upgrade -y

echo -e "${YLW}Installing dependencies...${RST}"

pkg install -y \
git \
python \
python-pip \
python-psutil \
clang \
rust \
make \
pkg-config \
libffi \
openssl \
nodejs \
ripgrep \
ffmpeg \
libandroid-spawn \
cmake

echo -e "${YLW}Removing old installation...${RST}"

rm -rf hermes-agent
rm -rf ~/.cache/pip

echo -e "${YLW}Cloning Hermes Agent...${RST}"

git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git

cd hermes-agent

echo -e "${YLW}Creating virtual environment...${RST}"

python -m venv venv

source venv/bin/activate

echo -e "${YLW}Upgrading pip tools...${RST}"

python -m pip install --upgrade pip setuptools wheel

# -------------------------------------------------
# IMPORTANT FIX
# Use Termux psutil instead of pip psutil
# -------------------------------------------------

echo -e "${YLW}Installing Termux-compatible packages...${RST}"

python -m pip install \
cython \
numpy \
wheel

export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"

# Prevent pip from trying to build psutil
export PIP_NO_BUILD_ISOLATION=1

echo -e "${YLW}Installing Hermes Agent...${RST}"

python -m pip install -e '.[termux]' \
-c constraints-termux.txt \
--no-deps

echo -e "${YLW}Installing remaining dependencies safely...${RST}"

python -m pip install \
rich \
typer \
httpx \
pydantic \
uvicorn \
fastapi

echo -e "${YLW}Creating hermes command...${RST}"

ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"

echo ""
echo -e "${GRN}=====================================================${RST}"
echo -e "${GRN}     ✅ Hermes Agent Installed Successfully${RST}"
echo -e "${GRN}=====================================================${RST}"

echo ""
echo "Run:"
echo "hermes"
echo "hermes setup"
echo "hermes gateway"
echo ""
