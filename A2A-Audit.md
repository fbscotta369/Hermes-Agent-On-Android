# A2A-Audit — Significant Action Log

Do not store secrets.

This file is append-oriented.

---

## AUDIT-001

Date: 2026-08-08

Agent: ZCode (mimo-v2.5-free)

Category: Configuration

Action: Installed A2A multi-agent development system into the repository.

Result: Created AGENTS.md, CLAUDE.md, A2A-How2.md, A2A-WIP.md, A2A-ArchMap.md,
A2A-Bugs.md, A2A-PTI.md, A2A-Audit.md, .env.example, .envrc, and scripts/
(project-context, agent-doctor, auth-status, agent-start). Updated .gitignore.

Commit: pending

Environment: local development (linux x64)

Related:

- ARCH-001
- ARCH-002
- ARCH-003

Notes: A2A system makes the repository ready for multi-agent development.
All previous work (audit + rewrite of installer and launchers) is already
committed as `12625ea`.

---

## AUDIT-002

Date: 2026-08-08

Agent: ZCode (mimo-v2.5-free)

Category: Destructive Operation

Action: Removed 4 legacy installer scripts that were superseded by nous_agent.sh.

Result: Deleted agent_install.sh, hermes_install.sh, proot_install.sh,
nous_hermes_agent_install.sh. These contained broken code (duplicate shebangs,
incompatible Python install methods, no proot-distro support).

Commit: 12625ea

Environment: local development (linux x64)

Related:

- ARCH-003

Notes: Legacy scripts were kept with ⚠️ warnings but never used. Removed
to reduce confusion.

---

## AUDIT-003

Date: 2026-08-08

Agent: ZCode (mimo-v2.5-free)

Category: Security

Action: Fixed POSIX-compatible grep in hermes-doctor (replaced grep -oP with cut).

Result: hermes-doctor now works on all grep implementations, not just PCRE-capable ones.

Commit: 12625ea

Environment: local development (linux x64)

Related:

- BUG-001 (historical, now fixed)

Notes: `grep -oP` requires PCRE support which is not available on all systems.
Used `cut -d. -f2` instead (POSIX-compatible).

---

## Template

```markdown
## AUDIT-NNN

Date: YYYY-MM-DD

Agent: ...

Category: Deployment / Architecture / Database / Authentication / Security /
Provider / Dependency / Infrastructure / Destructive Operation / Configuration

Action: ...

Result: ...

Commit: ...

Environment: ...

Related:

- BUG-...
- PTI-...
- ARCH-...

Notes: ...
```

Git remains the authoritative source for normal source-code history.
