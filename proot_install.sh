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
echo -e "${GRN}            HERMES AGENT INSTALLER"
echo -e "${CYN}=====================================================${RST}"

echo -e "${YLW}Updating packages...${RST}"

pkg update -y
pkg upgrade -y

echo -e "${YLW}Installing dependencies...${RST}"

pkg install -y \
git \
python \
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

echo -e "${YLW}Cleaning old files...${RST}"

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

echo -e "${YLW}Installing Android compatible psutil...${RST}"

python -m pip install "psutil==5.9.8"

echo -e "${YLW}Installing helper packages...${RST}"

python -m pip install cython numpy wheel

export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"

echo -e "${YLW}Installing Hermes Agent...${RST}"

python -m pip install -e '.[termux]' -c constraints-termux.txt

echo -e "${YLW}Creating global hermes command...${RST}"

ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"

echo ""
echo -e "${GRN}=====================================================${RST}"
echo -e "${GRN}      ✅ Hermes Agent Installed Successfully${RST}"
echo -e "${GRN}=====================================================${RST}"

echo ""
echo "Run:"
echo "hermes"
echo "hermes setup"
echo "hermes gateway"
echo ""
