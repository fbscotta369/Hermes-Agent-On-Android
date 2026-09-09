# A2A-Startup — Startup Instructions

## Purpose

How to start working on this repository.

## For AI Agents

1. Read `AIIA-START-HERE-AI-AGENT.md`
2. Read `A2A-WIP.md`
3. Read `A2A-Tasks.md`
4. Run `./scripts/agent-start`

## For Humans

```bash
git clone https://github.com/fbscotta369/Hermes-Agent-On-Android.git
cd Hermes-Agent-On-Android
bash -n nous_agent.sh
bash -n install.sh
bash -n scripts/*
```

## Before Making Changes

1. Inspect repository state: `git status`
2. Check branch: `git branch --show-current`
3. Review recent commits: `git log -5 --oneline`
4. Read `AGENTS.md` and `A2A-How2.md`
5. Understand existing implementation before changing it

## Validation

```bash
# Syntax-check all shell scripts
for f in nous_agent.sh install.sh scripts/*; do
  bash -n "$f" && echo "OK: $f" || echo "FAIL: $f"
done
```

## Canonical Docs

- Procedures: `A2A-How2.md`
- Quickstart: `A2A-Quickstart.md`
