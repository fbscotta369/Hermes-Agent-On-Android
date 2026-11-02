# A2A Hub — Multi-Agent Orchestration

Local hub for branch locking, task queue, and agent registry (part of distributed coordination).

## Files

- **agents.jsonl** — Active agents: agent_id, device, model, branch, task, status, heartbeat
- **tasks.jsonl** — Task queue: task_id, type, prerequisites, assignee, status
- **branches.json** — Branch→agent mapping: prevents concurrent writes to same branch
- **state-snapshots/** — Timestamped STATE.md copies from each completed task branch

## Workflow

1. Agent starts → registers in agents.jsonl → heartbeat updated
2. Agent polls tasks.jsonl → claims available task (prereqs met)
3. Agent locks branch in branches.json
4. Agent works on feature/task-<ID> branch
5. Agent pushes when complete → creates state-snapshot → releases lock
6. Next agent's task prerequisites now satisfied

See AGENTS.md (updated startup protocol) for agent responsibilities.
