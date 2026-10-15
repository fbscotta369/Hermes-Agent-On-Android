# ISSUES

Bugs and fixes in one place. Status: open | fixing | fixed | wontfix.

| ID | Status | Summary | Found by | Fix commit |
|---|---|---|---|---|
| BUG-001 | FIXED | `grep -oP` not POSIX-compatible; hermes-doctor fails on some systems | ZCode | 12625ea |
| BUG-002 | FIXED | Ubuntu detection via pipe-grep chains unreliable | ZCode | 12625ea |
| BUG-003 | FIXED | Python version extraction broken in installers | ZCode | 12625ea |
| BUG-004 | FIXED | hermes-update trap doesn't fire correctly | ZCode | 12625ea |
| BUG-005 | FIXED | install.sh sysconfig hack fragile | ZCode | 12625ea |

---

## Bug Registry

### BUG-001 — `grep -oP` not POSIX-compatible

**Status:** FIXED (verified 2026-09-08)

**Priority:** P2

**Discovered:** 2026-08-08

**Symptoms:** `hermes-doctor` fails on systems without PCRE grep support.

**Expected:** Works on all POSIX grep implementations.

**Actual:** Failed with "invalid option" on non-GNU grep.

**Reproduction:**
1. Run `hermes-doctor` on a system with BSD/macOS grep
2. Observe failure

**Suspected Cause:** Used `grep -oP` which requires PCRE support.

**Investigation:** Verified `cut -d. -f2` works everywhere.

**Files:**
- `scripts/hermes-doctor` (inline in `nous_agent.sh`)

**Resolution:** Replaced `grep -oP` with POSIX-compatible `cut` in commit 12625ea.

**Verification:** `bash -n` passes, manual test on multiple systems.

**Related:**
- ARCH-003
- AUDIT-003

---

### BUG-002 — Ubuntu detection via pipe-grep chains unreliable

**Status:** FIXED (verified 2026-09-08)

**Priority:** P1

**Discovered:** 2026-08-08

**Symptoms:** `proot-distro list | grep ...` gives false positives/negatives.

**Expected:** Reliable detection of installed Ubuntu.

**Actual:** Failed when output format changed.

**Reproduction:**
1. Install Ubuntu via proot-distro
2. Run installer again
3. Detection may fail

**Suspected Cause:** Parsing human-readable output is fragile.

**Investigation:** Filesystem check `[ -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/ubuntu" ]` is deterministic.

**Files:**
- `nous_agent.sh`
- `scripts/hermes-update`

**Resolution:** Switched to filesystem check in commit 12625ea.

**Verification:** Tested across multiple Termux versions.

**Related:**
- ARCH-001
- AUDIT-001

---

### BUG-003 — Python version extraction broken in installers

**Status:** FIXED (verified 2026-09-08)

**Priority:** P2

**Discovered:** 2026-08-08

**Symptoms:** Installer couldn't determine Python version correctly.

**Expected:** Extract major.minor version reliably.

**Actual:** Failed on some Python version strings.

**Reproduction:**
1. Run installer on Ubuntu with Python 3.11+
2. Observe version extraction

**Suspected Cause:** Regex too strict or relied on specific output format.

**Files:**
- `nous_agent.sh`
- `install.sh`

**Resolution:** Fixed extraction logic in commit 12625ea.

**Verification:** Tested with Python 3.11, 3.12, 3.13.

**Related:**
- ARCH-002
- AUDIT-001

---

### BUG-004 — hermes-update trap doesn't fire correctly

**Status:** FIXED (verified 2026-09-08)

**Priority:** P2

**Discovered:** 2026-08-08

**Symptoms:** EXIT trap in gateway/updater scripts didn't execute on failure.

**Expected:** Trap fires on any exit (success, error, signal).

**Actual:** `exec` replaced the process, preventing trap.

**Reproduction:**
1. Run `hermes-gateway` with invalid config
2. Observe missing Telegram offline notification

**Suspected Cause:** Used `exec proot-distro` which replaces shell process.

**Investigation:** Gateway pattern must NOT use `exec` on the proot-distro line.

**Files:**
- `scripts/hermes-gateway`
- `scripts/hermes-update`

**Resolution:** Removed `exec` from proot-distro calls in commit 12625ea.

**Verification:** Telegram offline notification fires on Ctrl+C, crash, error.

**Related:**
- ARCH-003

---

### BUG-005 — install.sh sysconfig hack fragile

**Status:** FIXED (verified 2026-09-08)

**Priority:** P3

**Discovered:** 2026-08-08

**Symptoms:** Direct Termux install failed on some Python versions.

**Expected:** Works across Python 3.11-3.13.

**Actual:** sysconfig hack broke with newer Python.

**Reproduction:**
1. Run `install.sh` on Termux
2. Observe Python installation issues

**Suspected Cause:** Direct manipulation of Python's sysconfig is version-sensitive.

**Investigation:** Using `uv` for Python management eliminates this entirely.

**Files:**
- `install.sh`

**Resolution:** Rewrote to use `uv` like main installer in commit 12625ea.

**Verification:** Tested on Termux with various Python versions.

**Related:**
- ARCH-002

---

## Fixes & Remediation Log

### 2026-09-08 (commit bbf3090)

- Bumped Hermes Agent from v2026.7.7.2 to v2026.9.7 (latest stable)
- Updated `nous_agent.sh` HERMES_TAG environment variable
- Updated version badge in README.md (v0.18.2 → v2026.9.7)
- Updated installation examples throughout docs
- Ensures users get latest version "out of the box"

### 2026-08-08 (commit 12625ea)

- Fixed Ubuntu detection (filesystem check instead of pipe-grep chains)
- Fixed Python version extraction
- Fixed hermes-update trap
- Fixed install.sh sysconfig hack
- Replaced `grep -oP` with POSIX-compatible `cut` in hermes-doctor
- Rewrote `nous_agent.sh` and all launcher scripts
- Removed 4 broken legacy installer scripts (agent_install.sh, hermes_install.sh, proot_install.sh, nous_hermes_agent_install.sh)

### 2026-10-15 (this session)

- Migrated all legacy A2A-*.md files to new a2a/ structure
- Installed A2A Kit (a2a.sh) with hooks and handoff protocol
- Created a2a/TECHNICAL.md, WHAT.md, TASKS.md, ISSUES.md, DECISIONS.md, STATE.md, LOG.md
- All 11 shell scripts verified with `bash -n`

---

## Current State

No critical open bugs tracked. All known issues fixed.

## How to Add an Issue

1. Add entry to table above with next ID (BUG-006)
2. Fill in bug details below using template
3. When fixed, update status and add fix commit
4. Add fix note to "Fixes & Remediation Log"

## Template

```markdown
### BUG-NNN — Short Title

**Status:** NEW

**Priority:** P1 / P2 / P3 / P4

**Discovered:** YYYY-MM-DD

**Symptoms:**
...

**Expected:**
...

**Actual:**
...

**Reproduction:**
1. ...
2. ...

**Suspected Cause:**
...

**Investigation:**
...

**Files:**
- ...

**Resolution:**
Pending

**Verification:**
Pending

**Related:**
- PTI-...
- ARCH-...
- AUDIT-...
```