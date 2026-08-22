# A2A-Bugs — Bug Registry

Allowed statuses:

- NEW
- INVESTIGATING
- BLOCKED
- FIXED
- VERIFIED
- REOPENED
- WONTFIX
- CLOSED

---

_No bugs currently tracked. Add new bugs below following the template._

---

## Template

```markdown
## BUG-NNN — Short Title

Status: NEW

Priority: P1 / P2 / P3 / P4

Discovered: YYYY-MM-DD

### Symptoms

...

### Expected

...

### Actual

...

### Reproduction

1. ...
2. ...

### Suspected Cause

...

### Investigation

...

### Files

- ...

### Resolution

Pending

### Verification

Pending

### Related

- PTI-...
- ARCH-...
- AUDIT-...
```

<!-- AIIA-FACTORY-VERIFIED-2026-08-22 -->
## AIIA Factory Verification — 2026-08-22

Verified 2026-08-22: `bash -n` on all shell scripts clean (3 scripts).

Part of Task Group **TG-AIIA-FACTORY-2026-08-22** (control plane: `/home/fb/Downloads/A2A-SHARED-PROGRESS.md`).
Verified by **direct execution** under AIIA DR-1 — the `delegate_task` subagent channel returned `HTTP 401` (OpenRouter key not propagated to child); the orchestrator executed the verification directly.
