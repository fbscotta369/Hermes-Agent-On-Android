# TECHNICAL

## Architecture

This is a **shell-script-only packaging repository**. It does not contain application code — it installs and configures the Nous Research Hermes Agent (a Python package from a separate repository) to run on Android via Termux.

```
User's Android Device
       |
       v
   Termux (shell environment)
       |
       +---- Launcher scripts ($PREFIX/bin/hermes, hermes-gateway, etc.)
       |
       +---- proot-distro (Ubuntu container, no root required)
               |
               +---- Ubuntu 24.04/25.04
                      |
                      +---- uv (Python version manager)
                      |
                      +---- Python 3.11-3.13 virtual environment
                      |
                      +---- Hermes Agent (NousResearch/hermes-agent)
                             |
                             +---- AI Provider APIs (Google, OpenAI, Anthropic, etc.)
                             |
                             +---- Telegram Bot API (optional notifications)
```

## Components

### nous_agent.sh (One-Line Installer)

Path: `nous_agent.sh`

Responsibilities:
- Pre-flight checks (Android version, storage, internet)
- Install proot-distro + Ubuntu if missing
- Clone Hermes Agent repository inside Ubuntu
- Set up Python venv via `uv`
- Install Hermes Agent Python package
- Deploy launcher scripts to `$PREFIX/bin/`
- Install hermes-doctor inline

Dependencies: Termux, proot-distro, curl, git

### install.sh (Direct Termux Installer)

Path: `install.sh`

Responsibilities:
- Alternative installer that runs Hermes directly in Termux (no proot-distro)
- Uses `uv` for Python version management

Dependencies: Termux, curl, git

### scripts/hermes (Launcher)

Path: `scripts/hermes`

Responsibilities:
- Transparently enters Ubuntu, activates venv, runs `hermes` command
- Passes all arguments through

Pattern: `exec proot-distro login ubuntu -- bash -c '...' -- "$@"`

### scripts/hermes-gateway (Gateway Launcher)

Path: `scripts/hermes-gateway`

Responsibilities:
- Pre-flight API key check (shows configured provider)
- Sends Telegram "online" notification on start
- Runs Hermes gateway (does NOT use exec — EXIT trap must fire)
- Sends Telegram "offline" notification on stop (via EXIT trap)
- Shows actionable error diagnostics on failure

Design decision: No `exec` on proot-distro so bash trap fires correctly.

### scripts/hermes-doctor (Diagnostics)

Path: `scripts/hermes-doctor`

Responsibilities:
- 6-step diagnostic: Termux env, internet, installation, launchers, API keys, Telegram
- Returns exit code 1 on failures, 0 on pass/warnings
- Uses POSIX-compatible grep (no `grep -oP`)

### scripts/hermes-update (Updater)

Path: `scripts/hermes-update`

Responsibilities:
- Downloads latest launcher scripts from GitHub
- Updates Python package inside Ubuntu
- Supports `--edge` flag for main branch tracking

Design decision: No `exec` on proot-distro so bash can return after proot completes.

### scripts/hermes-setup (Setup Launcher)

Path: `scripts/hermes-setup`

Responsibilities:
- Runs `hermes setup` inside Ubuntu for first-time configuration

### scripts/uninstall.sh (Removal)

Path: `scripts/uninstall.sh`

Responsibilities:
- Removes launcher scripts from `$PREFIX/bin/`
- Removes hermes-agent directory inside Ubuntu
- Optionally removes Ubuntu proot-distro entirely

### scripts/a2a.sh (Handoff Kit)

Path: `scripts/a2a.sh`

Responsibilities:
- A2A handoff protocol: init, resume, handoff, check, doctor, start, soul
- Used by Claude hooks and git pre-push guard

## Data Flow

### Installation Flow

```
curl | bash nous_agent.sh
  -> pkg install proot-distro
  -> proot-distro install ubuntu
  -> proot-distro login ubuntu
     -> apt install system deps
     -> git clone hermes-agent
     -> uv venv --python ">=3.11,<3.14"
     -> uv pip install -e ".[all]"
  -> Deploy launchers to $PREFIX/bin/
  -> Done
```

### Runtime Flow (hermes command)

```
User types: hermes <args>
  -> $PREFIX/bin/hermes (Termux launcher)
  -> exec proot-distro login ubuntu -- bash -c 'cd ~/hermes-agent && source venv/bin/activate && exec hermes "$@"' -- <args>
  -> Hermes Agent runs inside Ubuntu
```

### Update Flow

```
User types: hermes-update
  -> Downloads launcher scripts from GitHub (raw.githubusercontent.com)
  -> proot-distro login ubuntu
     -> git pull (or fetch + reset)
     -> uv pip install -e ".[all]"
  -> Done
```

## Infrastructure

- **Hosting:** GitHub repository (fbscotta369/Hermes-Agent-On-Android)
- **Distribution:** raw.githubusercontent.com for script downloads
- **No CI/CD** — manual testing on physical Android devices
- **No database** — stateless installer
- **No container registry** — uses proot-distro from Termux repos

## External Services

| Service | Purpose | Auth |
|---------|---------|------|
| GitHub (NousResearch/hermes-agent) | Source code for Hermes Agent | Public repo, no auth |
| GitHub (fbscotta369/Hermes-Agent-On-Android) | This installer repo | Public repo, no auth |
| Google AI API | Gemini model access | API key (env var) |
| OpenAI API | GPT model access | API key (env var) |
| Anthropic API | Claude model access | API key (env var) |
| Telegram Bot API | Gateway notifications | Bot token + chat ID (env var) |
| Astral (uv) | Python version management | No auth (public installer) |

## Architecture Decisions

### ARCH-001 — Use proot-distro instead of direct Termux

Status: ACTIVE

Date: 2026-07 (inherited from original project)

Decision: Run Hermes Agent inside proot-distro Ubuntu, not directly in Termux.

Reason: Many Python packages (including Hermes dependencies) require a full Linux userspace. proot-distro provides this without root access.

Consequences: Adds complexity (nested environments), but provides compatibility.

### ARCH-002 — Use uv for Python version management

Status: ACTIVE

Date: 2026-07

Decision: Use Astral's `uv` to manage Python versions instead of `apt install python3`.

Reason: Ubuntu 25.04 ships Python 3.14 which is incompatible with Hermes (requires <3.14). `uv venv --python ">=3.11,<3.14"` automatically downloads a compatible version.

Consequences: Adds a dependency on `uv`, but eliminates fragile sysconfig hacks and apt version pinning.

### ARCH-003 — Monolithic installer with inline heredocs

Status: ACTIVE

Date: 2026-07

Decision: `nous_agent.sh` contains all launcher scripts as inline heredocs, deployed to `$PREFIX/bin/` during installation.

Reason: Enables the one-liner `curl | bash` installation pattern. Standalone copies in `scripts/` are refreshed by `hermes-update`.

Consequences: Changes to launchers require updating both `nous_agent.sh` and `scripts/` copies. `hermes-update` synchronizes them from GitHub.

## Config and Secrets

Where each value comes from (env var, secret store, CI). Never the values themselves.

| Variable | Source | Required For |
|----------|--------|--------------|
| `GOOGLE_API_KEY` / `GEMINI_API_KEY` | Termux `~/.bashrc` | Gemini |
| `OPENAI_API_KEY` | Termux `~/.bashrc` | GPT |
| `ANTHROPIC_API_KEY` | Termux `~/.bashrc` | Claude |
| `HERMES_TELEGRAM_BOT_TOKEN` | Termux `~/.bashrc` | Notifications (optional) |
| `HERMES_TELEGRAM_CHAT_ID` | Termux `~/.bashrc` | Notifications (optional) |

Never store credential values in A2A files or source code.

## Build and Deploy

- **Build:** N/A (shell-script-only project)
- **Deploy:** Push to `main` branch. Users pull via:
  - `hermes-update` — refreshes launchers + Python package (stable, latest tag)
  - `hermes-update --edge` — tracks main branch
  - One-liner installer: `curl -fsSL .../nous_agent.sh | bash` (always pulls from main)

## Verification (A→Z)

Commands, steps and expected results that prove the thing works.

1. `bash -n nous_agent.sh` → exit 0 (syntax OK)
2. `bash -n install.sh` → exit 0 (syntax OK)
3. `bash -n scripts/*` → exit 0 (all scripts syntax OK)
4. `hermes-doctor` → all 6 checks pass (PASS), 0 failures
5. `hermes setup` → completes first-time configuration
6. `hermes gateway` → starts gateway, Telegram "online" fires (if configured)
7. `hermes-update` → refreshes launchers, updates package, reports success
7. `hermes-update --edge` → tracks main branch, reports success

### Syntax Check All Scripts

```bash
for f in nous_agent.sh install.sh scripts/*; do
  bash -n "$f" && echo "OK: $f" || echo "FAIL: $f"
done
```

## Stack

- **Language:** Bash (POSIX-compatible where possible)
- **Runtime:** Termux on Android
- **Container:** proot-distro Ubuntu
- **Python Manager:** uv (Astral)
- **Python Range:** >=3.11, <3.14
- **Package:** Hermes Agent v2026.9.7 from NousResearch/hermes-agent

## Key Patterns

### Launcher Pattern

```bash
exec proot-distro login ubuntu -- bash -c '
cd "$HOME/hermes-agent" && source venv/bin/activate && exec hermes "$@"
' -- "$@"
```

### Gateway Pattern (no exec — trap must fire)

```bash
GATEWAY_EXIT=0
proot-distro login ubuntu -- bash -c '...' -- "$@" || GATEWAY_EXIT=$?
```

### Ubuntu Detection

Filesystem check is the only reliable method:

```bash
if [ -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
    UBUNTU_INSTALLED=true
fi
```

## Cross-Platform Test Matrix

| Android API | Termux Version | Architecture | Proot-Distro | Status | Notes |
|-------------|----------------|--------------|--------------|--------|-------|
| 30 (Android 11) | 0.118+ | arm64 | Ubuntu 24.04 | ✅ Tested | Minimum supported |
| 31 (Android 12) | 0.118+ | arm64 | Ubuntu 24.04 | ✅ Tested | |
| 32 (Android 12L) | 0.118+ | arm64 | Ubuntu 24.04 | ✅ Tested | |
| 33 (Android 13) | 0.118+ | arm64 | Ubuntu 24.04 | ✅ Tested | |
| 34 (Android 14) | 0.118+ | arm64 | Ubuntu 24.04 | ✅ Tested | |
| 35 (Android 15) | 0.118+ | arm64 | Ubuntu 25.04 | ✅ Tested | Python 3.14 handled by uv |
| 29 (Android 10) | Any | arm64 | N/A | ❌ Unsupported | API < 30 |

### Tested Configurations

- **Termux**: 0.118.0, 0.119.0 (F-Droid & Play Store)
- **Proot-Distro**: Ubuntu 24.04 LTS, Ubuntu 25.04
- **Python**: 3.11.9, 3.12.4, 3.13.0 (managed by uv)
- **Architectures**: arm64 (primary), armv7 (untested)

### Known Issues

| Platform | Issue | Workaround |
|----------|-------|------------|
| Android 10 (API 29) | proot-distro not supported | Not supported |
| Ubuntu 25.04 | Python 3.14 default | uv auto-selects compatible version |
| Termux Play Store | Older version (0.101) | Use F-Droid version |

## Version History

| Version | Release Date | Notes |
|---------|--------------|-------|
| v2026.9.7 | 2026-09-08 | Latest stable (pinned in nous_agent.sh) |
| v2026.7.7.2 | 2026-07-07 | Previous stable release |

## Canonical Docs

- **Handoff:** `a2a/STATE.md` ← START HERE for next agent
- Architecture: `a2a/TECHNICAL.md` (this file)
- Operations: `a2a/TECHNICAL.md` (build/deploy/verification sections)
- Tasks: `a2a/TASKS.md` (12 completed: T1-T12)
- Bugs: `a2a/ISSUES.md`
- Fixes: `a2a/ISSUES.md` (merged)
- Pending Implementation: `a2a/ISSUES.md` (PTI items)
- Current Work: `a2a/STATE.md`
- Legacy files: `a2a/legacy/` (to be deleted after migration)

## AIIA Factory Verification — 2026-09-08

Verified 2026-09-08: `bash -n` on all shell scripts clean (11 scripts).

Part of Task Group **TG-AIIA-FACTORY-2026-09-08** (control plane: `/home/fb/Downloads/A2A-SHARED-PROGRESS.md`).
Verified by **direct execution** under Kimi Code CLI.