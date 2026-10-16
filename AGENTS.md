# AGENTS.md — Hermes Agent for Android (Termux)

Shared instructions for every coding agent on this repo: Codex, Hermes Agent and Antigravity read this file directly; Claude Code reads it via CLAUDE.md. Keep it under ~8,000 characters. Detail goes in `a2a/`.

## Start here
1. `git pull --rebase`
2. Read `a2a/STATE.md`: current objective, what's in progress, next steps.
3. Open other `a2a/` files only when STATE.md or the task needs them.

## Project
- **What it is:** Shell-script installer packaging Nous Research Hermes Agent for Android via Termux + proot-distro Ubuntu
- **Stack:** Bash, Termux, proot-distro, uv (Python manager), Python 3.11-3.13
- **URL / deployment:** GitHub Pages (repo), raw.githubusercontent.com (installer), user devices (runtime)
- **Status:** Production (v2026.9.7)

## Commands
- Install: `curl -fsSL .../nous_agent.sh | bash` (recommended) or `install.sh` (direct Termux)
- Run: `hermes` / `hermes gateway`
- Test: `hermes-doctor` (full diagnostics)
- Lint: `bash -n` on all `.sh` files, `shellcheck` (if available)

## Conventions
- POSIX-compatible Bash where possible
- `exec proot-distro login ubuntu -- bash -c '...' -- "$@"` for launchers
- Gateway: NO `exec` on proot-distro (EXIT trap must fire)
- Python via `uv venv --python ">=3.11,<3.14"` (not apt)
- Ubuntu detection: filesystem check `[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]`
- All scripts must pass `bash -n`

## Handoff protocol (A2A)
- After each completed task or meaningful commit: overwrite `a2a/STATE.md`, append `a2a/LOG.md`, update TASKS / ISSUES / DECISIONS if touched, commit, push.
- The pre-push hook blocks pushes when code changed after the last STATE.md update. Fix the handoff; do not bypass it.
- Do not reverse a decision in `a2a/DECISIONS.md` without FB's agreement.
- Business facts live in `a2a/WHAT.md`. Never guess them: write UNKNOWN and ask FB.
- Feature branches, merge to main when tests pass. No force-push. No secrets in git.

## a2a/ files
| File | Purpose |
|---|---|
| STATE.md | Current state and next steps. Overwritten on every update. Read first. |
| LOG.md | Append-only session log. |
| TASKS.md | In progress, next, backlog, done. |
| ISSUES.md | Bugs and fixes, with status and fix commit. |
| DECISIONS.md | Why X and not Y. |
| TECHNICAL.md | Architecture, specs, config sources, A→Z verification steps. |
| WHAT.md | Product and business facts (Q&A). |
| CHANGELOG.md | User-facing release notes. |

## Style
- FB is a senior SRE/DevOps engineer. Be direct and technical, British English, no filler.