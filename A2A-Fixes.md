# A2A-Fixes — Fixes & Remediation Log

## Purpose

Record of fixes applied to this repository.

## Recent Fixes

### 2026-09-08 (commit bbf3090)

- Bumped Hermes Agent from v2026.7.7.2 to v2026.9.7 (latest stable)
- Updated `nous_agent.sh` HERMES_TAG environment variable
- Updated version badge in README.md (v0.18.2 → v2026.9.7)
- Updated installation examples throughout docs
- Ensures users get latest version "out of the box"

## Historical Fixes

### 2026-08-08 (commit 12625ea)

- Fixed Ubuntu detection (filesystem check instead of pipe-grep chains)
- Fixed Python version extraction
- Fixed hermes-update trap
- Fixed install.sh sysconfig hack
- Replaced `grep -oP` with POSIX-compatible `cut` in hermes-doctor
- Rewrote `nous_agent.sh` and all launcher scripts
- Removed 4 broken legacy installer scripts

## Current State

No critical open fixes tracked. See `A2A-Bugs.md` for defect registry.

## How to Add a Fix

1. Record the bug in `A2A-Bugs.md` with status NEW
2. Fix the code
3. Update the bug status to FIXED/VERIFIED
4. Add a note here if the fix is significant (date, commit hash, what changed)
