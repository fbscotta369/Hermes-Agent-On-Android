# A2A-Tests — Testing

## Purpose

Testing strategy and validation procedures.

## Current State

No automated test suite exists. This is a shell-script-only project.

## Manual Validation

### Syntax Checks
```bash
bash -n nous_agent.sh
bash -n install.sh
bash -n scripts/hermes
bash -n scripts/hermes-setup
bash -n scripts/hermes-gateway
bash -n scripts/hermes-doctor
bash -n scripts/hermes-update
bash -n scripts/uninstall.sh
bash -n scripts/agent-start
bash -n scripts/agent-doctor
bash -n scripts/auth-status
bash -n scripts/project-context
```

### On-Device Testing
1. Clean install on Android device (or wipe Termux data)
2. Run one-liner installer
3. Verify all 6 launcher commands exist
4. Run `hermes-doctor` — all checks pass
5. Run `hermes setup` — first-time config works
6. Run `hermes gateway` — Telegram notifications fire
7. Run `hermes-update` — refreshes launchers and package

## Planned (PTI-001)

GitHub Actions CI to run `bash -n` on all scripts and verify executable
permissions automatically.

## Canonical Docs

- Pending work: `A2A-PTI.md`
- Procedures: `A2A-How2.md`
