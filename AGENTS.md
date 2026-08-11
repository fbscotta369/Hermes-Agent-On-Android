# Multi-Agent A2A Development Rules

This repository is developed by multiple interchangeable AI coding agents.

Agents may be switched at any time because of:

- rate limits
- context limits
- provider availability
- task specialization
- tool availability
- human preference

The repository therefore uses the A2A protocol for persistent handoff.

---

## PROJECT AUTO-DETECTION

Never assume the repository name or absolute path.

Determine the repository root with:

    git rev-parse --show-toplevel

If Git metadata is unavailable, use the current working directory.

Determine the repository name from the repository root.

Determine the Git remote with:

    git remote get-url origin

Do not hardcode project-specific paths in persistent agent instructions unless
the project explicitly requires an absolute path.

---

## MANDATORY STARTUP

Before performing substantial work:

1. Determine the repository root.
2. Change to the repository root if necessary.
3. Read `AGENTS.md`.
4. Read `A2A-How2.md`.
5. Read `A2A-WIP.md`.
6. Read other A2A files relevant to the current task.
7. Inspect repository state:

       git status
       git branch --show-current
       git log -5 --oneline

8. Understand the existing implementation before changing it.
9. If authentication, APIs, databases, deployments, external services or
   credentials may be involved, run:

       ./scripts/agent-doctor

10. Continue from the documented state.
11. Do not redo work already completed by another agent.

---

## A2A CONTINUOUS SYNCHRONIZATION — MANDATORY

A2A documentation is part of the development workflow.

It is not optional documentation.

### `A2A-WIP.md`

`A2A-WIP.md` is the live shared memory between AI agents.

Update it continuously during substantial work.

Update it when:

- a task is started
- an important discovery is made
- an implementation decision is made
- architecture relevant to the current task changes
- files are created, removed, renamed or substantially changed
- a bug is discovered
- a bug is fixed
- a blocker appears
- a workaround is introduced
- build/test/lint/typecheck status changes materially
- external service configuration changes
- a deployment occurs
- a milestone is completed
- the implementation plan changes
- work is about to stop
- another agent may take over

Do not leave important project state only in conversational context.

Before stopping substantial work, ensure `A2A-WIP.md` accurately represents
the repository state and the exact recommended next action.

### `A2A-How2.md`

Update `A2A-How2.md` only when persistent operational knowledge changes.

Examples:

- setup
- commands
- workflows
- tooling
- authentication procedures
- environment requirements
- deployment procedures
- testing procedures
- development conventions

Do not use `A2A-How2.md` as a session log.

### `A2A-ArchMap.md`

Update when persistent architecture changes.

Examples:

- components
- services
- data flows
- provider relationships
- infrastructure
- major dependencies
- ownership boundaries

### `A2A-Bugs.md`

Update whenever known defects change state.

Examples:

- discovered
- reproduced
- investigation updated
- blocked
- fixed
- verified
- reopened
- closed

### `A2A-PTI.md`

Update whenever pending implementation work changes.

Examples:

- new task
- reprioritized
- ready
- in progress
- blocked
- done
- cancelled

### `A2A-Audit.md`

Record significant historical actions.

Examples:

- production deployments
- schema migrations
- security-sensitive changes
- authentication configuration changes
- major dependency upgrades
- destructive operations
- architecture decisions
- provider changes

Do not duplicate normal Git history here.

---

## A2A ROUTING RULE

Route information according to purpose:

    Current active work         -> A2A-WIP.md
    Permanent procedures        -> A2A-How2.md
    Architecture                -> A2A-ArchMap.md
    Known defects               -> A2A-Bugs.md
    Future implementation work  -> A2A-PTI.md
    Significant historical acts -> A2A-Audit.md

When information belongs to another A2A file, `A2A-WIP.md` should reference
the relevant ID instead of duplicating the full record.

---

## IDENTIFIERS

Use stable IDs:

    BUG-001
    PTI-001
    ARCH-001
    AUDIT-001

Never reuse an ID for a different record.

---

## CREDENTIAL POLICY

Never ask the human for credential VALUES until existing authentication
mechanisms have been checked.

Before requesting credentials:

1. Run `./scripts/agent-doctor`.
2. Check authenticated CLIs.
3. Check whether the required environment variable exists.
4. Check whether the service uses an OS-native credential store.
5. Check documented project authentication procedures.

Prefer authenticated CLIs and native credential stores over raw API keys.

Never write secrets to:

- `AGENTS.md`
- `CLAUDE.md`
- any `A2A-*.md`
- README files
- source code
- Git commits
- GitHub issues
- logs
- screenshots
- test fixtures unless explicitly designed for safe fake credentials

Never display secret values unless explicitly required by the human.

Never run broad environment-dump commands merely to find credentials:

    env
    printenv
    set
    export -p

Check only the required variable by name.

Example:

    if [[ -n "${OPENAI_API_KEY:-}" ]]; then
        echo "OPENAI_API_KEY: available"
    else
        echo "OPENAI_API_KEY: missing"
    fi

Never echo the value.

---

## AUTHENTICATION PREFERENCE

Prefer persistent CLI authentication where supported.

Examples:

GitHub:
    gh auth login

Vercel:
    vercel login

Supabase:
    supabase login

Google Cloud:
    gcloud auth login
    gcloud auth application-default login

API providers:
    use project-scoped environment variables

Never expose an authentication token simply because an AI agent can execute a
CLI command that already has the required capability.

---

## SECRET LOCATION

Project-local secrets should be loaded from a directory outside Git:

    ~/.config/a2a-projects/<project-slug>/

Agents may verify that a required variable exists.

Agents must not dump entire secret files.

---

## GIT SAFETY

Never commit secrets.

Never use destructive Git operations without understanding current state.

Avoid blind:

    git add .

when secret or unrelated files may exist.

Inspect:

    git status

before commits.

Do not discard unrelated work from humans or other agents.

---

## HANDOFF

Before stopping substantial work:

1. Update `A2A-WIP.md`.
2. Record unfinished work.
3. Record blockers.
4. Record tests/build status.
5. Record exact next action.
6. Update specialized A2A documents when their state changed.
7. Ensure no important information exists only in chat context.

The next AI agent should be able to continue without asking the human to
reconstruct the previous session.
## Shared startup contract
- Before starting a new app or resuming an existing app, read `/home/fb/hermes-agent-backup/Hermes Agent BackUp GitHub Repo/A2A-AIIA-Labs-Multi-Agent-pp-Factory-Development-System-v369.md`.
- Then follow this repo's local startup docs before acting.
