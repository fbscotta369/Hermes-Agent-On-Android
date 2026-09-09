# AIIA Orchestration

## Hermes Role

Hermes delegates, monitors, retries, and completes tasks across agents.

## Agent Role

Agents execute repo-local work and update A2A files.

## Status Flow

queued -> validating_repo -> running -> completed
queued -> validating_repo -> blocked
running -> switching_cli -> running
running -> switching_provider -> running
running -> using_local_fallback -> running
running -> failed

## Blocker Rules

Only escalate blockers that require human judgment or credentials.

## Recovery Rules

New agents must resume from:

1. `AIIA-START-HERE-AI-AGENT.md`
2. `A2A-WIP.md`
3. `A2A-Tasks.md`
4. Other relevant project docs
