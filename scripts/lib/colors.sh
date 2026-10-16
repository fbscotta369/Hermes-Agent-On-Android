#!/data/data/com.termux/files/usr/bin/bash
# lib/colors.sh — Color definitions and output helpers

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
RST='\033[0m'
BLD='\033[1m'
DIM='\033[2m'

# Output helpers
step()   { echo -e "${GRN}━━━ ${CYN}$*${RST}"; }
info()   { echo -e "${GRN}  → $*${RST}"; }
warn()   { echo -e "${YLW}  ⚠️  $*${RST}"; }
fail()   { echo -e "${RED}  ❌ $*${RST}"; exit 1; }
ok()     { echo -e "${GRN}  ✅ $*${RST}"; }
debug()  { [ "${DEBUG:-}" = "1" ] && echo -e "${DIM}  [DEBUG] $*${RST}"; }

# Spinner for long operations
spinner_pid=""
start_spinner() {
    local msg="${1:-Working...}"
    echo -ne "${CYN}  ⟳ ${msg}${RST}"
    (
        local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        local i=0
        while true; do
            printf "\r${CYN}  ${spin:i++%${#spin}:1} ${msg}${RST}"
            sleep 0.1
        done
    ) &
    spinner_pid=$!
}

stop_spinner() {
    local status="${1:-done}"
    local msg="${2:-}"
    if [ -n "$spinner_pid" ]; then
        kill "$spinner_pid" 2>/dev/null || true
        wait "$spinner_pid" 2>/dev/null || true
        spinner_pid=""
    fi
    case "$status" in
        ok)    echo -e "\r${GRN}  ✅ ${msg}${RST}" ;;
        fail)  echo -e "\r${RED}  ❌ ${msg}${RST}" ;;
        warn)  echo -e "\r${YLW}  ⚠️  ${msg}${RST}" ;;
        *)     echo -e "\r${GRN}  ✅ ${msg}${RST}" ;;
    esac
}

# Banner
show_banner() {
    local title="$1"
    local subtitle="${2:-}"
    clear
    echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
    echo -e "${GRN}         ☤  ${title}  ☤${RST}"
    if [ -n "$subtitle" ]; then
        echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
        echo -e "${GRN}                ${subtitle}${RST}"
    fi
    echo -e "${CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
    echo ""
}