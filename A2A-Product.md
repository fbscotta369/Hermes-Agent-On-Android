# A2A-Product — Product Context

## Purpose

Product description and scope for this repository.

## What This Is

A packaging layer that installs the Nous Research Hermes Agent (a Python AI
framework) onto Android devices via Termux.

## What This Is NOT

- The Hermes Agent application itself (that's `NousResearch/hermes-agent`)
- A general Android app (no APK, no Play Store)
- A hosted service (runs entirely on the user's device)

## Value Proposition

- One-command installation on Android
- Automatic Ubuntu + Python environment setup
- Transparent launcher commands (`hermes`, `hermes-gateway`, etc.)
- Built-in diagnostics (`hermes-doctor`)
- Self-updating (`hermes-update`)

## User Journey

1. User runs `curl | bash` one-liner in Termux
2. Installer sets up Ubuntu + Python + Hermes Agent
3. User types `hermes setup` once
4. User types `hermes` or `hermes gateway` to run
5. User types `hermes-update` to get latest version

## Canonical Docs

- User docs: `README.md`
- Architecture: `A2A-ArchMap.md`
