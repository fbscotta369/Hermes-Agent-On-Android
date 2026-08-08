# A2A-PTI — Pending To Implement

Allowed statuses:

- IDEA
- READY
- IN_PROGRESS
- BLOCKED
- DONE
- CANCELLED

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
