# A2A-Technical — Technical Reference

## Purpose

Technical details and implementation notes.

## Stack

- **Language**: Bash (POSIX-compatible where possible)
- **Runtime**: Termux on Android
- **Container**: proot-distro Ubuntu
- **Python Manager**: uv (Astral)
- **Python Range**: >=3.11, <3.14
- **Package**: Hermes Agent v2026.9.7 from NousResearch/hermes-agent

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

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `GOOGLE_API_KEY` / `GEMINI_API_KEY` | Google Gemini |
| `OPENAI_API_KEY` | OpenAI |
| `ANTHROPIC_API_KEY` | Anthropic |
| `HERMES_TELEGRAM_BOT_TOKEN` | Telegram bot |
| `HERMES_TELEGRAM_CHAT_ID` | Telegram chat |

## Version History

| Version | Release Date | Notes |
|---------|--------------|-------|
| v2026.9.7 | 2026-09-08 | Latest stable (pinned in nous_agent.sh) |
| v2026.7.7.2 | 2026-07-07 | Previous stable release |

## Canonical Docs

- **Handoff:** `HANDOFF.md` ← **START HERE** for next agent
- Architecture: `A2A-ArchMap.md`
- Operations: `A2A-How2.md`
- Tasks: `A2A-Tasks.md` (12 completed: T1-T12)
- Bugs: `A2A-Bugs.md`
- Fixes: `A2A-Fixes.md`
- Pending Implementation: `A2A-PTI.md`
- Current Work: `A2A-WIP.md`
