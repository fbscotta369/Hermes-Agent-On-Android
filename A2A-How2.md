# A2A-How2 — Persistent Project Procedures

## Purpose

This file contains long-lived project operating knowledge.

Do not use it as a temporary session log.

## Project Detection

Repository root:

    git rev-parse --show-toplevel

Repository name:

    basename "$(git rev-parse --show-toplevel)"

Remote:

    git remote get-url origin

## Project Overview

**Hermes Agent for Android (Termux)** — packages the [Nous Research Hermes Agent](https://github.com/NousResearch/hermes-agent) for running on Android devices via Termux + proot-distro Ubuntu.

- **Repository:** `fbscotta369/Hermes-Agent-On-Android`
- **Primary installer:** `nous_agent.sh` (one-liner via `curl | bash`)
- **Alternative installer:** `install.sh` (direct Termux, no proot-distro)
- **Hermes Agent version:** v0.18.2 (pinned tag: `v2026.7.7.2`)
- **Python requirement:** >=3.11, <3.14 (Ubuntu 25.04 ships 3.14 which is incompatible)
- **Package manager:** `uv` (Astral) manages Python versions inside Ubuntu

## Architecture

This is a **shell-script-only** repository. There is no Python code, no package manifest, no CI/CD, and no tests in this repo. The actual Hermes Agent Python package is installed from `NousResearch/hermes-agent` at runtime.

The installer (`nous_agent.sh`) is monolithic (~745 lines) and contains launcher scripts as heredocs. The `scripts/` directory holds standalone copies that `hermes-update` refreshes from GitHub.

## Development Setup

No local development setup needed — this is a packaging/installer project. To test changes:

1. Edit scripts locally
2. Push to `main`
3. Test the one-liner installer on an Android device running Termux

## Key Commands

| Command | Context | Purpose |
|---------|---------|---------|
| `bash -n <script>` | Local | Syntax-check a bash script |
| `shellcheck <script>` | Local (if installed) | Lint bash scripts |
| `git status` | Local | Check working tree state |
| `git log -5 --oneline` | Local | Recent commits |

## Deployment

Changes are deployed by pushing to `main`. Users pull updates via:

```bash
hermes-update          # refreshes launchers + Python package
hermes-update --edge   # tracks main branch
```

The one-liner installer always pulls from `main`:

```bash
curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/nous_agent.sh | bash
```

## Testing on Device

There is no automated test suite. Manual testing procedure:

1. Clean install on a test device (or wipe Termux data)
2. Run the one-liner installer
3. Verify all 6 launcher commands exist: `hermes`, `hermes-setup`, `hermes-gateway`, `hermes-doctor`, `hermes-update`, `uninstall.sh`
4. Run `hermes-doctor` — all checks should pass
5. Run `hermes setup` — verify first-time configuration works
6. Run `hermes gateway` — verify Telegram notifications fire
7. Run `hermes-update` — verify it refreshes launchers and updates the package

## Authentication

This project does not use CLI authentication (no Vercel, Supabase, etc.).

API keys for AI providers are set as environment variables in Termux `~/.bashrc`:

- `GOOGLE_API_KEY` / `GEMINI_API_KEY` — Google Gemini
- `OPENAI_API_KEY` — OpenAI
- `ANTHROPIC_API_KEY` — Anthropic

Telegram notifications (optional):

- `HERMES_TELEGRAM_BOT_TOKEN`
- `HERMES_TELEGRAM_CHAT_ID`

## Environment Variables

| Variable | Purpose | Required |
|----------|---------|----------|
| `GOOGLE_API_KEY` | Google Gemini API access | Yes (for Gemini) |
| `GEMINI_API_KEY` | Alias for Google Gemini | No |
| `OPENAI_API_KEY` | OpenAI API access | Yes (for GPT) |
| `ANTHROPIC_API_KEY` | Anthropic API access | Yes (for Claude) |
| `HERMES_TELEGRAM_BOT_TOKEN` | Telegram bot for notifications | No |
| `HERMES_TELEGRAM_CHAT_ID` | Telegram chat for notifications | No |

Never store credential values in A2A files or source code.

## Important Conventions

- All Termux launchers use shebang: `#!/data/data/com.termux/files/usr/bin/bash`
- Launcher pattern: `exec proot-distro login ubuntu -- bash -c '...' -- "$@"`
- Gateway launcher does NOT use `exec` on proot-distro (so EXIT trap fires)
- Python version managed by `uv`, not `apt` (avoids sysconfig hacks)
- Ubuntu detection uses filesystem check, not pipe-grep chains (POSIX-compatible)
- All scripts must pass `bash -n` syntax check

## Agent Notes

Only persistent instructions belong here.

Temporary work belongs in `A2A-WIP.md`.
