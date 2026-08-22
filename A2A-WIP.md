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

## Related Records

- AUDIT-001 — A2A system installation (updated)
- PTI-001 — CI/CD Pipeline (IDEA)
- PTI-002 — a2a-check Validation Script (IDEA)
- PTI-003 — Pre-commit Secret Scanning (IDEA)

### Next action for next agent

```bash
cd /home/fb/Downloads/Projects/Git/Hermes-Agent-On-Android
./scripts/agent-start
```

Then read:

`AGENTS.md` → `A2A-WIP.md` → `A2A-How2.md` → relevant `A2A-PTI.md` item(s).

Continue from the current documented state. Do not restart completed work.

If a PTI is active, reference its exact ID here.

Then implement the first READY or IN_PROGRESS PTI item.

Currently all PTIs are IDEA, so the next agent should either:

1. Start implementing PTI-001 (CI/CD Pipeline)
2. Prioritize the highest value PTI based on project needs
3. Leave the backlog unchanged and continue with existing project work

<!-- AIIA-FACTORY-VERIFIED-2026-08-22 -->
## AIIA Factory Verification — 2026-08-22

Verified 2026-08-22: `bash -n` on all shell scripts clean (3 scripts).

Part of Task Group **TG-AIIA-FACTORY-2026-08-22** (control plane: `/home/fb/Downloads/A2A-SHARED-PROGRESS.md`).
Verified by **direct execution** under AIIA DR-1 — the `delegate_task` subagent channel returned `HTTP 401` (OpenRouter key not propagated to child); the orchestrator executed the verification directly.
