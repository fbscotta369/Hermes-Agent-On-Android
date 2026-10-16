# TASKS

## In progress

## Next

- Monitor user feedback from v2026.9.7 release

## Backlog

- PTI-001 — CI/CD Pipeline (P3) — *reverted per user request*

## Done

| Task ID | Title | Status | Type | Value | Agent | Completed | Commit |
|---------|-------|--------|------|-------|-------|-----------|--------|
| T1 | Initial repo analysis & A2A audit | COMPLETED | Risk Reduction | Foundation | Kimi Code CLI | 2026-09-08 | 93f2b98 |
| T2 | All shell scripts pass `bash -n` syntax check | COMPLETED | Quality Assurance | Verification | Kimi Code CLI | 2026-09-08 | 93f2b98 |
| T3 | Verify proot-distro Ubuntu detection (filesystem check) | COMPLETED | Bug Fix | Correctness | Unknown | 2026-08-08 | 12625ea |
| T4 | Fix Python version extraction in installers | COMPLETED | Bug Fix | Correctness | Unknown | 2026-08-08 | 12625ea |
| T5 | Fix hermes-update trap handling | COMPLETED | Bug Fix | Reliability | Unknown | 2026-08-08 | 12625ea |
| T6 | Replace `grep -oP` with POSIX-compatible `cut` | COMPLETED | Refactor | Compatibility | Unknown | 2026-08-08 | 12625ea |
| T7 | Rewrite `nous_agent.sh` monolithic installer | COMPLETED | Refactor | Maintainability | Unknown | 2026-08-08 | 12625ea |
| T8 | Rewrite all launcher scripts (hermes, hermes-setup, hermes-gateway, hermes-doctor, hermes-update, uninstall.sh) | COMPLETED | Refactor | Maintainability | Unknown | 2026-08-08 | 12625ea |
| T9 | Remove 4 legacy broken installer scripts | COMPLETED | Cleanup | Maintainability | Unknown | 2026-08-08 | 12625ea |
| T10 | Add full A2A coordination system (AGENTS.md + A2A-*.md) | COMPLETED | Documentation | Process | Unknown | 2026-08-08 | 4d4589d |
| T11 | Stamp factory verification (all A2A files + README) | COMPLETED | Documentation | Quality | Kimi Code CLI | 2026-09-08 | 93f2b98 |
| T12 | Bump Hermes Agent version v2026.7.7.2 → v2026.9.7 | COMPLETED | Feature | User Value | Claude Code (Haiku 4.5) | 2026-09-08 | bbf3090 |
| T13 | Create A2A-HANDOFF-SHEET.md and A2A-MASTER-REFERENCE.md | COMPLETED | Documentation | Process | Claude Code (Haiku 4.5) | 2026-09-11 | d3ad1c7 |
| T14 | Migrate legacy A2A-*.md to new a2a/ structure | COMPLETED | Documentation | Process | OpenCode | 2026-10-15 | ed5bf68 |
| T15 | Implement PTI-002: a2a-check Validation Script | COMPLETED | Feature | Process Enforcement | OpenCode | 2026-10-15 | c08ccd0 |
| T16 | Implement PTI-003: Pre-commit Secret Scanning | COMPLETED | Security | Defense-in-depth | OpenCode | 2026-10-15 | (this commit) |
| T17 | Add --latest flag to nous_agent.sh/install.sh (auto-discover tag) | COMPLETED | Feature | User Value | OpenCode | 2026-10-15 | improvements |
| T18 | Reduce AGENTS.md to under 8k chars (now 2569) | COMPLETED | Refactor | Process | OpenCode | 2026-10-15 | improvements |
| T19 | Add checksum verification framework (SHA256 placeholders) | COMPLETED | Security | Supply Chain | OpenCode | 2026-10-15 | improvements |
| T20 | Create modular libs (scripts/lib/colors,utils,telegram.sh) | COMPLETED | Refactor | Maintainability | OpenCode | 2026-10-15 | improvements |
| T21 | a2a-check validates AGENTS.md size | COMPLETED | Feature | Process | OpenCode | 2026-10-15 | improvements |
| T22 | shellcheck in pre-commit (warn only) | COMPLETED | Quality | Code Quality | OpenCode | 2026-10-15 | improvements |
| T23 | a2a doctor --fix auto-fix common issues | COMPLETED | Feature | Developer Experience | OpenCode | 2026-10-15 | improvements |
| T24 | bump-version script for automated version bumps | COMPLETED | Feature | Automation | OpenCode | 2026-10-15 | improvements |
| T25 | CHANGELOG.md user-facing release notes | COMPLETED | Documentation | User Value | OpenCode | 2026-10-15 | improvements |
| T26 | Enhanced uninstall.sh with verification | COMPLETED | Feature | Reliability | OpenCode | 2026-10-15 | improvements |
| T27 | Cross-platform test matrix in TECHNICAL.md | COMPLETED | Documentation | Quality | OpenCode | 2026-10-15 | improvements |
| T28 | Enhanced Telegram notifications (keyboard, rich formatting) | COMPLETED | Feature | User Value | OpenCode | 2026-10-15 | improvements |
| T29 | Spinner/progress indicators in installer | COMPLETED | Feature | Developer Experience | OpenCode | 2026-10-15 | improvements |

## Task Summary

- **Total completed:** 29 tasks
- **Current status:** All tracked tasks in COMPLETED state
- **Latest work:** All suggested improvements implemented except PTI-001 (2026-10-15)
- **Build status:** ✅ All 17 shell scripts pass `bash -n` syntax check
- **Next action:** Merge improvements branch to main, monitor user feedback from v2026.9.7 release