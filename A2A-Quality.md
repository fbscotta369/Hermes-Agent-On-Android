# A2A-Quality — Quality & Standards

## Purpose

Quality standards and validation rules for this repository.

## Current Quality Gates

| Gate | Rule | Status |
|------|------|--------|
| Bash syntax | All `.sh` and script files must pass `bash -n` | PASS |
| Permissions | Launcher scripts must be executable | PASS |
| No secrets | No credential values in committed files | PASS |
| A2A files | Required coordination files must exist | PASS |

## Code Style

- `set -euo pipefail` on all scripts
- Shebang: `#!/data/data/com.termux/files/usr/bin/bash` for Termux launchers
- Quoting: always quote variables (`"$VAR"`)
- Colors: use consistent color codes (RED, GRN, YLW, CYN, RST)

## Known Gaps

- No automated CI/CD (PTI-001)
- No shellcheck in CI
- No on-device automated tests
- No checksum verification for downloaded scripts

## Canonical Docs

- Procedures: `A2A-How2.md`
- Bugs: `A2A-Bugs.md`
