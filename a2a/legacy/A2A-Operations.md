# A2A-Operations — Operations

## Purpose

Operational procedures for maintaining this repository.

## Canonical Source

The authoritative operational procedures are in `A2A-How2.md`.

## Quick Reference

| Task | Command |
|------|---------|
| Syntax-check all scripts | `bash -n <script>` |
| Lint scripts | `shellcheck <script>` (if installed) |
| Check repo state | `git status` |
| Recent commits | `git log -5 --oneline` |
| A2A agent startup | `./scripts/agent-start` |
| A2A agent doctor | `./scripts/agent-doctor` |

## Deployment

Changes are deployed by pushing to `main`. Users pull updates via:

```bash
hermes-update          # refreshes launchers + Python package
hermes-update --edge   # tracks main branch
```

## Testing on Device

No automated test suite. Manual testing:
1. Clean install on test device
2. Verify all 6 launcher commands exist
3. Run `hermes-doctor`
4. Run `hermes setup`
5. Run `hermes gateway`
6. Run `hermes-update`

## Monitoring

- No production monitoring (installer is stateless)
- Telegram notifications optional for gateway runtime
