# A2A Quickstart — Hermes Agent for Android

## Project Elevator Pitch

Packages the Nous Research **Hermes Agent** (self-evolving AI framework) for Android devices running Termux + proot-distro Ubuntu. One-line installer; handles all dependencies including Python version management via `uv`.

## Quick Links

- **Repository:** `fbscotta369/Hermes-Agent-On-Android`
- **Latest version:** v2026.9.7 (Hermes Agent from NousResearch/hermes-agent)
- **Installer:** `nous_agent.sh` (745 lines, monolithic, includes launcher heredocs)
- **Type:** Shell-script-only (no Python code in this repo — packages Hermes Agent runtime)

## 30-Second Setup

```bash
# Clone repo
cd /home/fb/Downloads/Projects/Git/Hermes-Agent-On-Android

# Check status
git status --short

# View recent commits
git log -5 --oneline

# Syntax-check all scripts
bash -n scripts/*.sh nous_agent.sh install.sh
```

## What Lives Where

| Path | Purpose |
|------|---------|
| `nous_agent.sh` | One-liner installer (~745 lines, contains launcher heredocs) |
| `install.sh` | Direct Termux installer (alternative, no proot-distro) |
| `scripts/` | Standalone copies of launchers (refreshed by `hermes-update`) |
| `README.md` | User-facing install + feature documentation |
| `A2A-*` | Multi-agent coordination files |

## Key Commands

| Command | Purpose |
|---------|---------|
| `bash -n <script>` | Syntax-check a script |
| `git status` | Check working tree |
| `git log -5 --oneline` | Recent commits |
| `git push` | Deploy to `main` (users pull via `hermes-update`) |

## Resume Procedure

1. Read `AGENTS.md` (multi-agent rules)
2. Read `A2A-WIP.md` (current work state)
3. Read `A2A-How2.md` (persistent procedures)
4. Read `A2A-Tasks.md` (task registry)
5. Run `git status && git log -5 --oneline` (inspect current state)
6. Continue next incomplete task from `A2A-Tasks.md` or `A2A-PTI.md`

## No Local Setup Required

This is a **packaging/installer project**. No local development environment needed. To test:

1. Edit scripts locally
2. Push to `main`
3. Test one-liner on Android device running Termux

## Related Files

- `A2A-How2.md` — Persistent procedures (setup, testing, deployment)
- `A2A-Technical.md` — Stack, patterns, environment variables
- `A2A-Tasks.md` — Task registry (completed + pending)
- `A2A-Bugs.md` — Bug registry
- `A2A-Fixes.md` — Fixes applied
