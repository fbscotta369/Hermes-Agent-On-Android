# A2A-Controls — Controls & Compliance

## Purpose

Security and operational controls for this repository.

## Current Controls

| Control | Status | Evidence |
|---------|--------|----------|
| No secrets in source | PASS | `.env.example` has empty values; `.gitignore` blocks secrets |
| Shell script syntax check | PASS | `bash -n` clean on all 11 scripts |
| Executable permissions | PASS | All launcher scripts are executable |
| A2A handoff docs | PASS | All required files present and current |

## Missing Controls

| Control | Priority | Tracking |
|---------|----------|----------|
| CI/CD pipeline | P3 | PTI-001 |
| Pre-commit secret scanning | P3 | PTI-003 |
| a2a-check validation script | P4 | PTI-002 |

## Secret Handling

- API keys: env-var only (`~/.bashrc` on device)
- Telegram tokens: env-var only
- No credential files committed
- Project secrets stored outside Git: `~/.config/a2a-projects/hermes-agent-on-android/`

## Policy

See `SECURITY-POLICY.md` for full AI agent secret handling rules.
