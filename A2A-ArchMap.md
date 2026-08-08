# A2A-ArchMap — Architecture Map

Last verified: 2026-08-08

## System Overview

This is a **shell-script-only packaging repository**. It does not contain
application code — it installs and configures the Nous Research Hermes Agent
(a Python package from a separate repository) to run on Android via Termux.

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

Reason: Many Python packages (including Hermes dependencies) require a
full Linux userspace. proot-distro provides this without root access.

Consequences: Adds complexity (nested environments), but provides compatibility.

### ARCH-002 — Use uv for Python version management

Status: ACTIVE

Date: 2026-07

Decision: Use Astral's `uv` to manage Python versions instead of `apt install python3`.

Reason: Ubuntu 25.04 ships Python 3.14 which is incompatible with Hermes
(requires <3.14). `uv venv --python ">=3.11,<3.14"` automatically downloads
a compatible version.

Consequences: Adds a dependency on `uv`, but eliminates fragile sysconfig hacks
and apt version pinning.

### ARCH-003 — Monolithic installer with inline heredocs

Status: ACTIVE

Date: 2026-07

Decision: `nous_agent.sh` contains all launcher scripts as inline heredocs,
deployed to `$PREFIX/bin/` during installation.

Reason: Enables the one-liner `curl | bash` installation pattern. Standalone
copies in `scripts/` are refreshed by `hermes-update`.

Consequences: Changes to launchers require updating both `nous_agent.sh` and
`scripts/` copies. `hermes-update` synchronizes them from GitHub.
