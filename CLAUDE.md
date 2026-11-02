# Project Instructions

@AGENTS.md

**47.5/10 - RAMAS AISLADAS, NO COMPARTIDAS** *(Isolated branches, not shared)*
- **Date:** 2026-11-02
- **Reason:** Hundreds of agents working in parallel need isolated workspaces
- **Action:** Each agent works on feature/task-<ID> branch; main stays owner-controlled
- **Implementation:** Hub enforces branch locks; agents claim tasks; no force-push

**48.5/10 - HUB COORDINA, AGENTES EJECUTAN** *(Hub coordinates, agents execute)*
- **Date:** 2026-11-02
- **Reason:** Delegation at scale requires a registry, not manual routing
- **Action:** a2a/hub/ tracks agents, tasks, locks; agents register on startup
- **Implementation:** Task assignment via hub; MCP for external event routing

**49.5/10 - SNAPSHOTS DE ESTADO POR RAMA** *(State snapshots per branch)*
- **Date:** 2026-11-02
- **Reason:** Each branch's STATE.md is frozen at completion; hub aggregates
- **Action:** On task complete, push a2a/STATE.md and create timestamped snapshot
- **Implementation:** a2a/hub/state-snapshots/<branch>-state-<timestamp>.md
