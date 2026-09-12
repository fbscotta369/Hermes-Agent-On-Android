# A2A-PTI — Pending To Implement

**Last Updated:** 2026-09-11

**Summary:** 3 items in IDEA state, ready for next agent to prioritize and implement.

**Recommendation for next agent:** Start with **PTI-001** (CI/CD) for production stability.

---

## Status Overview

| ID | Title | Status | Priority | Effort | Value |
|---|---|---|---|---|---|
| PTI-001 | CI/CD Pipeline | IDEA | P3 | Medium | High (production safety) |
| PTI-002 | a2a-check Script | IDEA | P4 | Low | Medium (process enforcement) |
| PTI-003 | Pre-commit Secret Scanning | IDEA | P3 | Low | High (security) |

---

## Allowed Statuses

- IDEA — Concept, not yet prioritized
- READY — Prioritized, specifications clear, ready to implement
- IN_PROGRESS — Currently being worked on
- BLOCKED — Waiting on external dependency
- DONE — Completed
- CANCELLED — No longer needed

---

## PTI-001 — CI/CD Pipeline

Status: IDEA

Priority: P3

### Goal

Add GitHub Actions CI to validate scripts on every push.

### Why

Currently all validation is manual (`bash -n`, on-device testing). A CI
pipeline could syntax-check all bash scripts and verify file permissions
automatically.

### Dependencies

- None

### Acceptance Criteria

- [ ] GitHub Actions workflow that runs `bash -n` on all `.sh` and script files
- [ ] Validates file permissions (launchers must be executable)
- [ ] Validates no secrets appear in committed files

### Suggested Files

- `.github/workflows/ci.yml`

### Implementation Notes

Use a simple Ubuntu runner with `bash` and `shellcheck`. No Docker needed.

### Related

- ARCH-003

---

## PTI-002 — a2a-check Validation Script

Status: IDEA

Priority: P4

### Goal

Create `scripts/a2a-check` that validates A2A protocol compliance.

### Why

Makes A2A compliance machine-enforced rather than relying on agent discipline.

### Dependencies

- None

### Acceptance Criteria

- [ ] Checks all A2A files exist
- [ ] Checks for duplicate BUG/PTI IDs
- [ ] Checks A2A-WIP.md is not stale
- [ ] Checks no obvious secrets in A2A files

### Suggested Files

- `scripts/a2a-check`

### Implementation Notes

Follow the spec in section 33 of the A2A document.

### Related

- None

---

## PTI-003 — Pre-commit Secret Scanning

Status: IDEA

Priority: P3

### Goal

Add a Git pre-commit hook that prevents committing secrets.

### Why

Defense-in-depth — catches mistakes before they reach the repository.

### Dependencies

- None

### Acceptance Criteria

- [ ] Pre-commit hook checks for API key patterns (sk-, AIza-, etc.)
- [ ] Hook can be installed via `./scripts/install-hooks`
- [ ] Does not block legitimate code

### Suggested Files

- `scripts/install-hooks`
- `.githooks/pre-commit`

### Implementation Notes

Simple grep-based check. No external dependencies.

### Related

- None

---

## Template

```markdown
## PTI-NNN — Short Title

Status: IDEA

Priority: P1 / P2 / P3 / P4

### Goal

...

### Why

...

### Dependencies

- ...

### Acceptance Criteria

- [ ] ...

### Suggested Files

- ...

### Implementation Notes

...

### Related

- BUG-...
- ARCH-...
- AUDIT-...
```

<!-- AIIA-FACTORY-VERIFIED-2026-09-11 -->
## AIIA Factory Verification — 2026-09-11

**Status:** ✅ VERIFIED & HANDOFF READY

- Original verification 2026-09-08: `bash -n` on all shell scripts clean (11 scripts)
- Handoff documentation completed 2026-09-11: HANDOFF.md created
- All PTI items clearly defined and prioritized
- Ready for next agent to implement

Part of Task Group **TG-AIIA-FACTORY-2026-09-08** (control plane: `/home/fb/Downloads/A2A-SHARED-PROGRESS.md`).
Verified by **Claude Code (Haiku 4.5)** through 2026-09-11.
