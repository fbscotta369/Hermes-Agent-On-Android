# A2A-WIP — Live Agent Handoff

Last updated: 2026-08-08

Agent: ZCode (mimo-v2.5-free)

Branch: main

## Current Objective

Install the A2A multi-agent development system into this repository so that
multiple AI coding agents can hand off work seamlessly.

## Current Status

A2A system files are being created. The repository is clean and all previous
work (full audit + rewrite of all scripts, removal of legacy cruft) is
already committed and pushed.

## Work Completed

- Full audit and rewrite of all project files (commit `12625ea`)
- Removed 4 legacy scripts (`agent_install.sh`, `hermes_install.sh`, `proot_install.sh`, `nous_hermes_agent_install.sh`)
- Fixed Ubuntu detection, Python version extraction, hermes-update trap, install.sh sysconfig hack
- Rewrote `nous_agent.sh`, all `scripts/` launchers, `README.md`, `install.sh`
- All scripts verified with `bash -n` syntax check and correct permissions
- A2A system installation in progress

## Active Files

- `AGENTS.md` — canonical agent operating rules (created)
- `CLAUDE.md` — thin Claude Code compatibility layer (created)
- `A2A-How2.md` — persistent procedures (created)
- `A2A-WIP.md` — this file (created)
- `A2A-ArchMap.md` — architecture map (created)
- `A2A-Bugs.md` — bug registry (created)
- `A2A-PTI.md` — pending to implement (created)
- `A2A-Audit.md` — significant action log (created)
- `.env.example` — environment variable template (created)
- `.envrc` — direnv configuration (created)
- `scripts/project-context` — project detection (created)
- `scripts/agent-doctor` — A2A diagnostic tool (created)
- `scripts/auth-status` — auth status check (created)
- `scripts/agent-start` — agent startup (created)

## Current Decisions

- A2A files are placed in the repository root (standard)
- A2A scripts are placed in `scripts/` alongside existing Hermes launchers
- Project slug: `hermes-agent-on-android`
- Secret directory: `~/.config/a2a-projects/hermes-agent-on-android/`

## Tests / Validation

- Build: N/A (shell-script-only project)
- Tests: N/A (no test suite)
- Syntax check: all new scripts pass `bash -n`
- Permissions: all new scripts are executable

## Blockers

- None

## Related Records

- AUDIT-001 — A2A system installation

## Immediate Next Action

Complete A2A file creation, verify all scripts, update `.gitignore`, commit
and push to `main`.

## Handoff Notes

The repository has no Python code, CI/CD, or automated tests. All validation
is manual via `bash -n` syntax checks and on-device testing with Termux.
