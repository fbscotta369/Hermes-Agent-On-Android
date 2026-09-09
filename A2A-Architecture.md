# A2A-Architecture — Architecture Notes

## Purpose

High-level architecture references for this repository.

## Canonical Source

The authoritative architecture documentation is in `A2A-ArchMap.md`.

## Quick Summary

This is a **shell-script-only packaging repository** that installs the Nous
Research Hermes Agent Python framework onto Android devices via Termux +
proot-distro Ubuntu.

```
Termux → proot-distro (Ubuntu) → uv → Python 3.11-3.13 venv → hermes-agent
```

## Components

- `nous_agent.sh` — one-line installer
- `install.sh` — direct Termux alternative
- `scripts/hermes*` — launcher scripts
- `scripts/uninstall.sh` — removal script

## Architecture Decisions

- ARCH-001 — Use proot-distro instead of direct Termux
- ARCH-002 — Use uv for Python version management
- ARCH-003 — Monolithic installer with inline heredocs

See `A2A-ArchMap.md` for full details.
