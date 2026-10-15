# A2A-Research — Research Notes

## Purpose

Research findings, technology evaluations, and external references.

## Technology Choices

### proot-distro vs. direct Termux

- **Chosen**: proot-distro Ubuntu
- **Reason**: Full Linux userspace required by many Python packages
- **Trade-off**: Adds complexity (nested environments) but improves compatibility

### uv vs. apt python3

- **Chosen**: Astral `uv`
- **Reason**: Ubuntu 25.04 ships Python 3.14 which is incompatible with Hermes
- **Trade-off**: Extra dependency, but eliminates fragile sysconfig hacks

### curl | bash vs. package manager

- **Chosen**: `curl | bash` for both the installer and `uv` installation
- **Risk**: No integrity verification
- **Mitigation**: Future PTI may add checksum verification

## External Dependencies

| Dependency | Source | Verification |
|------------|--------|--------------|
| Hermes Agent | GitHub (NousResearch/hermes-agent) | None (git clone) |
| uv installer | astral.sh | None (curl \| bash) |
| Launcher updates | GitHub raw content | None (curl download) |

## Canonical Docs

- Architecture: `A2A-ArchMap.md`
- Deep analysis: `A2A-DeepAnalysis.md`
