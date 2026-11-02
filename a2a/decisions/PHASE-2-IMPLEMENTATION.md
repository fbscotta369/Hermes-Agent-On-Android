# A2A Phase 2 Implementation Plan — Hybrid Hub Deployment

**Decision:** Hybrid Hub topology approved 2026-11-02  
**Target:** Deploy Phase 2 to all 19 repos  
**Timeline:** 2 weeks (pending owner approval per step)

---

## Phase 2 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ C3R3BRUM (Central Hub)                                  │
│ a2a/hub/                                                │
│ ├── agents.jsonl        [synced from all 19 repos]     │
│ ├── tasks.jsonl         [synced from all 19 repos]     │
│ ├── branches.json       [synced from all 19 repos]     │
│ └── state-snapshots/    [all repo snapshots]           │
└─────────────────────────────────────────────────────────┘
         ↑         ↑         ↑         ↑
    [poll]     [poll]     [poll]     [poll]
         ↓         ↓         ↓         ↓
    Repo A    Repo B    Repo C    ... Repo S
    (local)   (local)   (local)       (local)
  agents.json agents.json agents.json agents.json
  tasks.json  tasks.json  tasks.json  tasks.json
  (git sync every 30–60s)
```

---

## Phase 2a: Deploy Central Hub Polling Scripts

### Step 1: Create `a2a_hub_sync.py`

**Location:** `scripts/a2a_hub_sync.py`  
**Purpose:** Sync all repo hubs → C3R3BRUM central hub every 30–60 seconds

**Pseudocode:**
```python
def sync_all_repos():
    """Pull latest hub state from all 19 repos, merge into C3R3BRUM hub."""
    repos = load_repo_list()  # 19 repos from config
    
    for repo in repos:
        local_hub = repo / "a2a/hub/agents.jsonl"
        
        # Pull latest from remote
        run_cmd(f"cd {repo} && git pull --rebase")
        
        # Read local hub state
        agents = parse_jsonl(local_hub)
        tasks = parse_jsonl(repo / "a2a/hub/tasks.jsonl")
        
        # Merge into central hub
        merge_into_central_hub(repo.name, agents, tasks)
    
    # Write central hub
    write_central_hub()
    
    # Commit + push (if changed)
    run_cmd("cd C3R3BRUM && git add a2a/hub/ && git commit -m 'chore(a2a): hub sync' && git push")
```

**Implementation:**
- [ ] Write sync script
- [ ] Test with 2 repos (5 min test run)
- [ ] Verify central hub merges correctly
- [ ] Error handling: what if one repo unreachable?

### Step 2: Create `a2a_hub_register.py`

**Location:** `scripts/a2a_hub_register.py`  
**Purpose:** Agent registers itself in local hub; later synced to central hub

**Pseudocode:**
```python
def register_agent(agent_id, model, device, task_id):
    """Register agent in local repo hub."""
    entry = {
        "agent_id": agent_id,
        "model": model,
        "device": device,
        "branch": f"feature/task-{task_id}",
        "task": task_id,
        "status": "working",
        "last_heartbeat": now()
    }
    append_to_jsonl("a2a/hub/agents.jsonl", entry)
```

**Agent Workflow:**
```bash
# Agent A starts work
python scripts/a2a_hub_register.py \
  --agent-id hermes-001 \
  --model "Haiku 4.5" \
  --device "T3SL4X-40RUS" \
  --task task-landing-page

# ✅ Agent registered in a2a/hub/agents.jsonl
# Every 30–60s, C3R3BRUM syncs this to central hub
```

### Step 3: Create `a2a_hub_check.py`

**Location:** `scripts/a2a_hub_check.py`  
**Purpose:** Check if branch is locked; prevent concurrent edits

**Pseudocode:**
```python
def check_branch_lock(repo_name, branch_name):
    """Check if branch locked in central hub."""
    central_hub = read_json("C3R3BRUM/a2a/hub/branches.json")
    
    if central_hub[branch_name]["locked"]:
        agent_id = central_hub[branch_name]["agent_id"]
        print(f"Branch locked by {agent_id}")
        exit(1)
    else:
        print("Branch available")
        exit(0)
```

**Agent Workflow (Phase 2b):**
```bash
# Agent B wants to start work on feature/landing-page
python scripts/a2a_hub_check.py \
  --repo AIIA-Clarity \
  --branch feature/landing-page

# If locked: "Branch locked by Agent A (until 2026-11-02 15:30)"
# If available: Agent B can proceed
```

### Step 4: Wire Into CI/CD (Optional Phase 2b)

**Goal:** Auto-register agents, auto-check locks on branch creation

**Example (GitHub Actions):**
```yaml
name: A2A Hub Sync
on:
  schedule:
    - cron: '*/1 * * * *'  # Every 60 seconds

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: python scripts/a2a_hub_sync.py
```

---

## Phase 2b: Test With 2–3 Agents (Different Devices)

### Test Scenario 1: Local Task Assignment

```
Device 1 (Claude Code — laptop):
- Clone AIIA-Clarity
- python scripts/a2a_hub_register.py --agent-id claude-001 --task clarity-landing
- See task in a2a/hub/tasks.jsonl (local)
- Start work immediately (no network wait)

Device 2 (Codex — phone, offline):
- Clone AIIA-Clarity (offline)
- Registers locally: a2a/hub/agents.jsonl
- Works on local task (no internet needed)

Device 1 or 2 (when online):
- `git pull --rebase` syncs back to C3R3BRUM
- Central hub polls every 30s, sees both agents registered
```

### Test Scenario 2: Cross-Repo Task Discovery

```
Device 3 (Hermes — desktop):
- Clone AIIA-Clarity (local task queue empty)
- Queries C3R3BRUM/a2a/hub/tasks.jsonl (via `python scripts/a2a_hub_check.py`)
- Sees global tasks: API in M0N3YM4K3R (priority 1), eBook in AIIA-eBooks (priority 2)
- Chooses API task (higher priority)
- Switches to M0N3YM4K3R repo, works on it
- Central hub tracks: "Agent Hermes working on M0N3YM4K3R/feature/api"
```

### Test Checklist

- [ ] Agent registers locally in a2a/hub/agents.jsonl
- [ ] Central hub syncs agent registration within 60s
- [ ] Agent can query central hub for cross-repo tasks
- [ ] Branch lock prevents two agents from picking same branch
- [ ] Offline device can work locally, syncs when back online
- [ ] No race conditions: two agents don't duplicate work

---

## Phase 2 Rollout Schedule

### Week 1
- [ ] **Day 1–2:** Write scripts (a2a_hub_sync.py, a2a_hub_register.py, a2a_hub_check.py)
- [ ] **Day 3–4:** Local testing (Claude Code + Codex on 2 devices)
- [ ] **Day 5:** Bug fixes, add error handling

### Week 2
- [ ] **Day 1–3:** Test with Hermes Agent + other agent types
- [ ] **Day 4:** Document Phase 2 changes in AGENT-PROTOCOL.md
- [ ] **Day 5:** Deploy to all 19 repos (feature branch → main merge)

### Go-Live
- [ ] All agents switch to Phase 2 workflow
- [ ] Central hub polls every 30–60s
- [ ] Monitor for conflicts, race conditions

---

## File Changes Required

### Per Repo (19 repos)
```
a2a/hub/
├── agents.jsonl          [NO CHANGE — already template]
├── tasks.jsonl           [NO CHANGE — already template]
├── branches.json         [NO CHANGE — already template]
├── state-snapshots/      [NO CHANGE — already template]
├── README.md             [UPDATE: explain Phase 2 sync]
└── .gitignore            [ADD: ignore sync lock files]
```

### C3R3BRUM (Central Hub)
```
a2a/hub/
├── agents.jsonl          [NEW: merged from all 19 repos]
├── tasks.jsonl           [NEW: merged from all 19 repos]
├── branches.json         [NEW: merged from all 19 repos]
├── state-snapshots/      [NEW: snapshot archive]
└── sync-log.md           [NEW: track sync events]

scripts/
├── a2a_hub_sync.py       [NEW: polling script]
├── a2a_hub_register.py   [NEW: agent registration]
└── a2a_hub_check.py      [NEW: branch lock check]

.github/workflows/
└── a2a-hub-sync.yml      [NEW: CI trigger]
```

---

## Success Criteria

✅ **Phase 2 Complete When:**
1. Central hub syncs all 19 repos every 60 seconds
2. Agents can register and appear in central hub within 2 minutes
3. Cross-repo task assignment works (agent in Repo A can see/claim task from Repo B)
4. Branch locks prevent race conditions (verified with 2+ agents)
5. Offline agents work locally; sync when reconnected
6. Zero data loss or corruption during sync

---

## Known Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Central hub out of sync with repos | Sync script runs every 30s; conflicts logged |
| Two agents pick same task (race) | Branch lock checked before work starts |
| Network latency causes delays | Async sync; agents don't block on central hub |
| Offline agents miss updates | Local hub always available; sync on reconnect |
| Sync script crashes | Error logging + monitoring; retry on next cycle |

---

## Phase 2 Timeline Contingency

**If Phase 2a takes longer than expected:**
- Stay on Phase 1 (git-based) longer; it works
- Manually run sync script when needed
- Graduate to Phase 2 when ready

**If Phase 2b testing finds bugs:**
- Fix bugs in scripts
- Re-test with agents
- Delay rollout to all 19 repos (test on subset first)

---

## Next Decision Point

**Owner approves Phase 2a:** Start writing scripts  
**Owner requests changes:** Update this plan  
**Owner wants to wait:** Stay on Phase 1; revisit in 2 weeks

---

**Prepared by:** Haiku 4.5  
**Date:** 2026-11-02  
**Status:** READY FOR OWNER APPROVAL
