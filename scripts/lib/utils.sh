#!/data/data/com.termux/files/usr/bin/bash
# lib/utils.sh — Common utility functions

# Check if command exists
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Get Android SDK version
get_android_sdk() {
    getprop ro.build.version.sdk 2>/dev/null || echo 0
}

# Get available storage in MB
get_storage_mb() {
    df -m /data 2>/dev/null | awk 'NR==2 {print $4}' || echo 0
}

# Check internet connectivity
check_internet() {
    curl -s --max-time 10 https://github.com >/dev/null 2>&1
}

# Verify checksum (sha256)
verify_checksum() {
    local file="$1"
    local expected="$2"
    local actual
    actual=$(sha256sum "$file" 2>/dev/null | cut -d' ' -f1) || return 1
    [ "$actual" = "$expected" ]
}

# Download with checksum verification
download_verified() {
    local url="$1"
    local dest="$2"
    local expected_sha256="${3:-}"
    
    info "Downloading $(basename "$dest")..."
    curl -fsSL "$url" -o "$dest" || return 1
    
    if [ -n "$expected_sha256" ]; then
        info "Verifying checksum..."
        if ! verify_checksum "$dest" "$expected_sha256"; then
            warn "Checksum mismatch for $dest"
            rm -f "$dest"
            return 1
        fi
        ok "Checksum verified"
    fi
}

# Get latest Hermes tag from GitHub API
get_latest_hermes_tag() {
    local api_url="https://api.github.com/repos/NousResearch/hermes-agent/releases/latest"
    local tag
    
    tag=$(curl -fsSL "$api_url" 2>/dev/null | grep '"tag_name"' | head -1 | cut -d'"' -f4)
    if [ -n "$tag" ] && [[ "$tag" =~ ^v[0-9] ]]; then
        echo "$tag"
        return 0
    fi
    
    # Fallback: git ls-remote
    tag=$(git ls-remote --tags --sort=-version:refname https://github.com/NousResearch/hermes-agent.git 2>/dev/null | head -1 | cut -d'/' -f3)
    if [ -n "$tag" ] && [[ "$tag" =~ ^v[0-9] ]]; then
        echo "$tag"
        return 0
    fi
    
    return 1
}

# Get current Hermes version from local repo
get_current_hermes_version() {
    local repo_dir="$HOME/hermes-agent"
    if [ -d "$repo_dir/.git" ]; then
        cd "$repo_dir" && git describe --tags --always 2>/dev/null || echo "unknown"
    else
        echo "not-installed"
    fi
}

# Keep device awake
keep_awake() {
    termux-wake-lock 2>/dev/null || true
}

# Release wake lock
release_awake() {
    termux-wake-unlock 2>/dev/null || true
}

# Check if running in Termux
is_termux() {
    [ -n "${PREFIX:-}" ] && [[ "$PREFIX" == *"com.termux"* ]]
}

# Check if proot-distro Ubuntu is installed
is_ubuntu_installed() {
    # Strategy 1: Check proot-distro output
    if proot-distro list 2>/dev/null | grep -qi "ubuntu.*installed"; then
        return 0
    fi
    # Strategy 2: Check filesystem
    if [ -d "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
        return 0
    fi
    # Strategy 3: Try to run command
    if proot-distro login ubuntu -- echo ok >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Run command in Ubuntu proot
run_in_ubuntu() {
    proot-distro login ubuntu -- bash -c "$1"
}

# Run command in Ubuntu proot with heredoc support
run_in_ubuntu_script() {
    local script="$1"
    proot-distro login ubuntu -- bash -c "$script"
}

# Get Python version from Ubuntu venv
get_ubuntu_python_version() {
    run_in_ubuntu 'cd ~/hermes-agent && source venv/bin/activate && python --version 2>&1 | cut -d" " -f2'
}

# Check if a version is compatible (3.11 <= version < 3.14)
is_python_compatible() {
    local ver="$1"
    local major minor
    major=$(echo "$ver" | cut -d. -f1)
    minor=$(echo "$ver" | cut -d. -f2)
    [ "$major" -eq 3 ] && [ "$minor" -ge 11 ] && [ "$minor" -le 13 ]
}