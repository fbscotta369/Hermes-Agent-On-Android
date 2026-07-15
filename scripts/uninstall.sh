#!/data/data/com.termux/files/usr/bin/bash
#
# Hermes Agent for Android — Clean Uninstaller
# Repository: https://github.com/fbscotta369/Hermes-Agent-On-Android
#
# Usage: bash scripts/uninstall.sh
#    or: curl -fsSL .../scripts/uninstall.sh | bash
#
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; RST='\033[0m'

echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}      ☤  Hermes Agent — Uninstaller  ☤${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

# Confirmation
echo -e "${YLW}This will remove Hermes Agent and its environment from your device.${RST}"
echo -e "${YLW}Are you sure? (y/N)${RST}"
read -r confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

echo ""

# ── Step 1: Remove Termux-level launchers ──
echo -e "${GRN}  → Removing Termux launchers...${RST}"
for cmd in hermes hermes-setup hermes-update hermes-gateway hermes-doctor; do
    if [ -f "$PREFIX/bin/$cmd" ]; then
        rm -f "$PREFIX/bin/$cmd"
        echo "     Removed $PREFIX/bin/$cmd"
    fi
done

# ── Step 2: Remove Hermes Agent from inside Ubuntu ──
echo -e "${GRN}  → Removing Hermes Agent from Ubuntu...${RST}"
proot-distro login ubuntu -- bash -c '
set -euo pipefail
if [ -d "$HOME/hermes-agent" ]; then
    rm -rf "$HOME/hermes-agent"
    echo "     Removed ~/hermes-agent"
fi
if [ -f "$HOME/.local/bin/hermes" ]; then
    rm -f "$HOME/.local/bin/hermes"
    echo "     Removed ~/.local/bin/hermes"
fi
' 2>/dev/null || echo "     (Ubuntu not available, skipping)"

# ── Step 3: Optionally remove Ubuntu ──
echo ""
echo -e "${YLW}Remove the entire Ubuntu environment (proot-distro)?${RST}"
echo -e "${YLW}This frees up ~1-2 GB of storage. (y/N)${RST}"
read -r remove_ubuntu
if [ "$remove_ubuntu" = "y" ] || [ "$remove_ubuntu" = "Y" ]; then
    echo -e "${GRN}  → Removing Ubuntu...${RST}"
    proot-distro remove ubuntu 2>/dev/null || true
    echo "     Ubuntu removed"
fi

echo ""
echo -e "${GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "${GRN}     ✅  Hermes Agent has been removed.${RST}"
echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""
