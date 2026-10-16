#!/usr/bin/env bash
# a2a.sh — A2A handoff kit for Claude Code, Codex, Hermes Agent and Google Antigravity.
#
#   a2a install   once per machine: global rules + symlinks, Hermes SOUL, git defaults, `a2a` on PATH
#   a2a init      once per repo:    AGENTS.md, CLAUDE.md, a2a/, Claude hooks, pre-push guard
#   a2a resume    you, arriving at a machine:  pull, enable hooks, print STATE.md
#   a2a handoff   you, leaving a machine:      log, commit, push (asks before pushing a stale STATE)
#   a2a check     is the handoff current?      (used by the Claude Stop hook and git pre-push)
#   a2a check-all handoff + full a2a-check     (comprehensive validation)
#   a2a start     print session context        (used by the Claude SessionStart hook)
#   a2a soul      rebuild ~/.hermes/SOUL.md after editing GLOBAL.md
#   a2a doctor    show what each agent will load and what's misconfigured
#   a2a doctor --fix  auto-fix common issues (rebuild SOUL, reinstall hooks, init a2a)
set -euo pipefail

A2A_VERSION="1.0.0"
A2A_DIR="a2a"
A2A_HOME="${A2A_HOME:-$HOME/dotfiles/agents}"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
GEMINI_HOME="${GEMINI_HOME:-$HOME/.gemini}"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
GIT_NAME_DEFAULT="${A2A_GIT_NAME:-fbscotta369}"
GIT_EMAIL_DEFAULT="${A2A_GIT_EMAIL:-fbscotta@gmail.com}"
MARKER="A2A-GLOBAL-BEGIN"
SELF="$(readlink -f "${BASH_SOURCE[0]:-$0}")"

say()  { printf '\033[1;36m[a2a]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[a2a]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[a2a]\033[0m %s\n' "$*" >&2; exit 1; }
ts()   { date '+%Y-%m-%d %H:%M %Z'; }
host() { hostname -s 2>/dev/null || hostname; }
in_repo()   { git rev-parse --is-inside-work-tree >/dev/null 2>&1; }
repo_root() { git rev-parse --show-toplevel 2>/dev/null; }
branch()    { git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo main; }
stamp()     { date +%Y%m%d%H%M%S; }

# write stdin to $1 only if $1 doesn't exist
write_new() {
  local f="$1"
  if [ -e "$f" ]; then cat >/dev/null; say "keep $f"; return; fi
  mkdir -p "$(dirname "$f")"; cat >"$f"; say "new  $f"
}

# symlink $1 -> $2, backing up whatever was at $2
link_to() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then say "ok   $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(stamp)"
    warn "backed up existing $dst -> $dst.bak.* (merge anything useful into $A2A_HOME/GLOBAL.md)"
  fi
  ln -s "$src" "$dst"; say "link $dst -> $src"
}

fill() {
  # escape sed replacement metacharacters (\ & |) so odd repo names can't corrupt templates
  esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }
  sed -e "s|__NAME__|$(esc "${NAME:-repo}")|g" -e "s|__TS__|$(esc "${TS:-}")|g" \
      -e "s|__HOST__|$(esc "${HOST:-}")|g" -e "s|__BRANCH__|$(esc "${BR:-main}")|g"
}

# ───────────────────────────── templates ─────────────────────────────

tpl_global() { cat <<'EOF'
# Global agent rules (FB) — A2A handoff protocol
<!-- Source of truth: ~/dotfiles/agents/GLOBAL.md. Symlinked to ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md
     and ~/.gemini/GEMINI.md; embedded in ~/.hermes/SOUL.md by `a2a soul`. Edit the source, not the links. -->

Several AI agents (Claude Code, Codex, Hermes Agent, Antigravity) take turns on FB's repos, often mid-task,
across two Kubuntu machines (desktop and laptop). Another agent will pick up your work. Leave the repo so it can.

## Session start
1. Run `git status` and `git pull --rebase`. If the pull conflicts, stop and report.
2. If `a2a/STATE.md` exists, read it first, then only the files it points to.
3. The repo's AGENTS.md overrides this file on project specifics.
4. If the repo has no `a2a/` folder and the work is more than a quick question, suggest running `a2a init`.

## While working
- After each completed task or meaningful commit: overwrite `a2a/STATE.md`, append one line to `a2a/LOG.md`,
  update `a2a/TASKS.md`, `a2a/ISSUES.md` and `a2a/DECISIONS.md` if touched, then commit and push.
- You cannot see your usage limit or when your context will be compacted, so keep the handoff current as you go.
- Record non-obvious choices in `a2a/DECISIONS.md`. Do not reverse a logged decision without FB's agreement.
- Business facts (URL, products, prices, payment gateway, buyer persona, delivery) live in `a2a/WHAT.md`.
  Never guess them: write UNKNOWN and ask FB.

## Git
- Work on a feature branch; merge to main when tests pass. No force-push. No `--no-verify` — for you, the
  agents, there is no exception. (The only sanctioned one belongs to FB: `a2a handoff` pushes a confirmed
  WIP by appending a marker to STATE.md, never by skipping hooks.)
- A pre-push hook blocks pushes when code changed after the last STATE.md update. Fix the handoff instead.
- Git identity is set per machine by `a2a install`; do not change git config.
- Conventional commits (feat, fix, docs, chore, wip). Never commit secrets, tokens or .env files.

## Style
- FB is a senior SRE/DevOps engineer. Be direct and technical, British English, no filler.
EOF
}

tpl_agents() { cat <<'EOF'
# AGENTS.md — __NAME__

Shared instructions for every coding agent on this repo: Codex, Hermes Agent and Antigravity read this file
directly; Claude Code reads it via CLAUDE.md. Keep it under ~8,000 characters. Detail goes in `a2a/`.

## Start here
1. `git pull --rebase`
2. Read `a2a/STATE.md`: current objective, what's in progress, next steps.
3. Open other `a2a/` files only when STATE.md or the task needs them.

## Project
- What it is: TODO
- Stack: TODO
- URL / deployment: TODO
- Status: TODO (prototype / beta / production)

## Commands
- Install: `TODO`
- Run: `TODO`
- Test: `TODO`
- Lint / format: `TODO`

## Conventions
- TODO

## Handoff protocol (A2A)
- After each completed task or meaningful commit: overwrite `a2a/STATE.md`, append `a2a/LOG.md`,
  update TASKS / ISSUES / DECISIONS if touched, commit, push.
- The pre-push hook blocks pushes when code changed after the last STATE.md update. Fix the handoff; do not bypass it.
- Do not reverse a decision in `a2a/DECISIONS.md` without FB's agreement.
- Business facts live in `a2a/WHAT.md`. Never guess them: write UNKNOWN and ask FB.
- Feature branches, merge to main when tests pass. No force-push. No secrets in git.

## a2a/ files
| File | Purpose |
|---|---|
| STATE.md | Current state and next steps. Overwritten on every update. Read first. |
| LOG.md | Append-only session log. |
| TASKS.md | In progress, next, backlog, done. |
| ISSUES.md | Bugs and fixes, with status and fix commit. |
| DECISIONS.md | Why X and not Y. |
| TECHNICAL.md | Architecture, specs, config sources, A→Z verification steps. |
| WHAT.md | Product and business facts (Q&A). |
| BUSINESS.md | Marketing and monetisation, only if the repo sells something. |
| legacy/ | Old A2A-*.md files waiting to be folded in. Delete once migrated. |
EOF
}

tpl_state() { cat <<'EOF'
# STATE
Updated: __TS__ by a2a init @ __HOST__
Branch: __BRANCH__ | Tree: clean

## Objective
TODO: run the bootstrap prompt (Prompt 1 in A2A-PROMPT.md) to fill this in.

## In progress
- nothing yet

## Next steps
1. Run the bootstrap prompt
2.
3.

## Blockers / questions for FB
- none

## Gotchas
- none

## Verify
- `TODO test command` → expected result
EOF
}

tpl_log() { cat <<'EOF'
# LOG
Append-only, newest at the bottom. One line per session or handoff:
`- YYYY-MM-DD HH:MM TZ | agent | machine | branch | what changed | commits`

- __TS__ | a2a init | __HOST__ | __BRANCH__ | bootstrapped A2A kit | -
EOF
}

tpl_tasks() { cat <<'EOF'
# TASKS

## In progress

## Next

## Backlog

## Done
EOF
}

tpl_issues() { cat <<'EOF'
# ISSUES
Bugs and fixes in one place. Status: open | fixing | fixed | wontfix.

| ID | Status | Summary | Found by | Fix commit |
|---|---|---|---|---|
EOF
}

tpl_decisions() { cat <<'EOF'
# DECISIONS
One entry per non-obvious choice. Agents: don't reverse these without FB's agreement.

<!--
## D-001 — Title (YYYY-MM-DD, agent)
Context: what forced a choice
Decision: what we picked
Rejected: alternatives and why
Consequences: what this commits us to
-->
EOF
}

tpl_technical() { cat <<'EOF'
# TECHNICAL

## Architecture
TODO

## Components
TODO

## Data / storage
TODO

## Config and secrets
Where each value comes from (env var, secret store, CI). Never the values themselves.

## Build and deploy
TODO

## Verification (A→Z)
Commands, steps and expected results that prove the thing works.
1. `TODO` → expected
EOF
}

tpl_what() { cat <<'EOF'
# WHAT
Product and business facts. Only if this repo is a product, website or app; otherwise write N/A once and stop.
Agents: answer only what the code or FB proves. Anything else stays UNKNOWN until FB confirms.

1. **URL of this repo / website / app?**
   UNKNOWN
2. **Does it sell products? Which ones?**
   UNKNOWN
3. **Buyer persona and/or target audience?**
   UNKNOWN
4. **Payment options and payment gateway?**
   UNKNOWN
5. **Payment process?**
   UNKNOWN
6. **How is the product delivered to the buyer?**
   UNKNOWN
EOF
}

claude_hooks_json() { cat <<'EOF'
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/a2a.sh start" } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/a2a.sh check stop" } ] }
    ]
  }
}
EOF
}

tpl_prepush() { cat <<'EOF'
#!/usr/bin/env bash
# a2a pre-push guard: blocks pushes when code changed after the last a2a/STATE.md update
exec "$(git rev-parse --show-toplevel)/scripts/a2a.sh" check prepush
EOF
}

# ───────────────────────────── commands ─────────────────────────────

cmd_soul() {
  [ -f "$A2A_HOME/GLOBAL.md" ] || die "no $A2A_HOME/GLOBAL.md, run 'a2a install' first"
  local soul="$HERMES_HOME/SOUL.md" header="$A2A_HOME/SOUL-header.md" tmp
  mkdir -p "$HERMES_HOME"
  if [ ! -f "$header" ]; then
    if [ -f "$soul" ] && ! grep -q "$MARKER" "$soul"; then
      cp "$soul" "$header"; say "kept your existing Hermes persona as $header"
    else
      printf '# Hermes\nYou are Hermes, FB'"'"'s engineering agent. Direct, technical, British English.\n' >"$header"
      say "new  $header (Hermes persona; edit freely)"
    fi
  fi
  tmp="$(mktemp)"
  { cat "$header"; printf '\n\n<!-- %s: generated by `a2a soul` from %s. Edit that file, then rerun. -->\n\n' \
      "$MARKER" "$A2A_HOME/GLOBAL.md"; cat "$A2A_HOME/GLOBAL.md"; } >"$tmp"
  if [ -f "$soul" ] && cmp -s "$tmp" "$soul"; then rm -f "$tmp"; say "ok   $soul"; return; fi
  [ -f "$soul" ] && cp "$soul" "$soul.bak.$(stamp)"
  mv "$tmp" "$soul"; say "built $soul"
}

cmd_install() {
  mkdir -p "$A2A_HOME"
  tpl_global | write_new "$A2A_HOME/GLOBAL.md"
  link_to "$A2A_HOME/GLOBAL.md" "$CLAUDE_HOME/CLAUDE.md"
  link_to "$A2A_HOME/GLOBAL.md" "$CODEX_HOME/AGENTS.md"
  link_to "$A2A_HOME/GLOBAL.md" "$GEMINI_HOME/GEMINI.md"
  cmd_soul

  if [ "$SELF" != "$(readlink -f "$A2A_HOME/a2a.sh" 2>/dev/null || true)" ]; then
    cp "$SELF" "$A2A_HOME/a2a.sh"
  fi
  chmod +x "$A2A_HOME/a2a.sh"
  mkdir -p "$HOME/.local/bin"
  ln -sf "$A2A_HOME/a2a.sh" "$HOME/.local/bin/a2a"
  say "link $HOME/.local/bin/a2a"
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) warn "~/.local/bin isn't on PATH; add it to ~/.bashrc";; esac

  [ -n "$(git config --global user.name  || true)" ] || git config --global user.name  "$GIT_NAME_DEFAULT"
  [ -n "$(git config --global user.email || true)" ] || git config --global user.email "$GIT_EMAIL_DEFAULT"
  git config --global pull.rebase true
  git config --global rebase.autoStash true
  git config --global push.autoSetupRemote true
  say "git: $(git config --global user.name) <$(git config --global user.email)>, pull.rebase, autoStash, autoSetupRemote"

  if git -C "$A2A_HOME" rev-parse >/dev/null 2>&1; then
    say "$A2A_HOME is in git: commit and push it so the other machine gets the same rules"
  else
    warn "$A2A_HOME isn't in git. Make ~/dotfiles a private repo so desktop and laptop stay in sync."
  fi
  warn "Antigravity: don't use '+ Global' in its UI; it writes into ~/.gemini/GEMINI.md (your symlinked GLOBAL.md)."
  say "done. Next: cd into a repo and run 'a2a init'"
}

cmd_hooks() {
  local cur; cur="$(git config --get core.hooksPath || true)"
  if [ -z "$cur" ] || [ "$cur" = ".githooks" ]; then
    git config core.hooksPath .githooks; say "core.hooksPath=.githooks (pre-push guard active in this clone)"
  else
    warn "core.hooksPath is '$cur'; add 'scripts/a2a.sh check prepush' to that pre-push hook yourself"
  fi
  [ -f .githooks/pre-push ] && chmod +x .githooks/pre-push
  [ -f scripts/a2a.sh ] && chmod +x scripts/a2a.sh
  return 0
}

cmd_init() {
  local root; root="$(repo_root)" || die "not inside a git repo (git init first)"
  cd "$root"
  NAME="$(basename "$root")"; TS="$(ts)"; HOST="$(host)"; BR="$(branch)"
  export NAME TS HOST BR
  local clean_index=1
  git rev-parse --verify HEAD >/dev/null 2>&1 && ! git diff --cached --quiet && clean_index=0

  mkdir -p "$A2A_DIR" scripts .githooks .claude

  # old A2A-*.md files -> a2a/legacy/
  shopt -s nullglob; local legacy=(A2A-*.md a2a-*.md); shopt -u nullglob
  if [ ${#legacy[@]} -gt 0 ]; then
    mkdir -p "$A2A_DIR/legacy"
    local f; for f in "${legacy[@]}"; do
      if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then git mv "$f" "$A2A_DIR/legacy/"; else mv "$f" "$A2A_DIR/legacy/"; fi
    done
    say "moved ${#legacy[@]} legacy file(s) to $A2A_DIR/legacy/ (the bootstrap prompt folds them in)"
  fi

  # files that would shadow AGENTS.md in Hermes or override it in Antigravity
  for f in .hermes.md HERMES.md AGENTS.override.md GEMINI.md; do
    [ -e "$f" ] || continue
    if [ -L "$f" ] && [ "$(readlink -f "$f")" = "$root/AGENTS.md" ]; then rm "$f"; say "removed $f (symlink to AGENTS.md, loads it twice)"; continue; fi
    mkdir -p "$A2A_DIR/legacy"
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then git mv "$f" "$A2A_DIR/legacy/$f"; else mv "$f" "$A2A_DIR/legacy/$f"; fi
    warn "moved $f to $A2A_DIR/legacy/ (it shadows or overrides AGENTS.md)"
  done

  # AGENTS.md is canonical; CLAUDE.md is a pointer
  if [ ! -e AGENTS.md ] && [ -f CLAUDE.md ] && ! grep -q '^@AGENTS.md' CLAUDE.md; then
    { tpl_agents | fill; printf '\n## Imported from the old CLAUDE.md (tidy this up)\n\n'; cat CLAUDE.md; } > AGENTS.md
    printf '@AGENTS.md\n' > CLAUDE.md
    say "moved CLAUDE.md content into AGENTS.md; CLAUDE.md is now a pointer"
  else
    tpl_agents | fill | write_new AGENTS.md
    if ! grep -q 'a2a/STATE.md' AGENTS.md; then
      printf '\n## Handoff protocol (A2A)\nRead `a2a/STATE.md` first. After each completed task: update a2a/STATE.md and a2a/LOG.md, commit, push.\n' >> AGENTS.md
      say "appended A2A section to existing AGENTS.md"
    fi
    if [ ! -e CLAUDE.md ]; then printf '@AGENTS.md\n' > CLAUDE.md; say "new  CLAUDE.md"
    elif ! grep -q '^@AGENTS.md' CLAUDE.md; then
      { printf '@AGENTS.md\n\n'; cat CLAUDE.md; } > CLAUDE.md.tmp && mv CLAUDE.md.tmp CLAUDE.md
      warn "prepended @AGENTS.md to CLAUDE.md; move anything shared into AGENTS.md"
    fi
  fi

  tpl_state     | fill | write_new "$A2A_DIR/STATE.md"
  tpl_log       | fill | write_new "$A2A_DIR/LOG.md"
  tpl_tasks     |        write_new "$A2A_DIR/TASKS.md"
  tpl_issues    |        write_new "$A2A_DIR/ISSUES.md"
  tpl_decisions |        write_new "$A2A_DIR/DECISIONS.md"
  tpl_technical |        write_new "$A2A_DIR/TECHNICAL.md"
  tpl_what      |        write_new "$A2A_DIR/WHAT.md"

  # repo-local copy of this script so hooks work in any clone, with or without `a2a install`
  if [ "$SELF" != "$(readlink -f scripts/a2a.sh 2>/dev/null || true)" ]; then cp "$SELF" scripts/a2a.sh; say "copy scripts/a2a.sh (v$A2A_VERSION)"; fi
  chmod +x scripts/a2a.sh

  if [ ! -e .githooks/pre-push ] || grep -q 'a2a' .githooks/pre-push; then
    tpl_prepush > .githooks/pre-push; chmod +x .githooks/pre-push; say "hook .githooks/pre-push"
  else
    warn ".githooks/pre-push exists; add: \"\$(git rev-parse --show-toplevel)/scripts/a2a.sh\" check prepush"
  fi
  cmd_hooks

  local settings=.claude/settings.json
  if [ ! -e "$settings" ]; then
    claude_hooks_json > "$settings"; say "new  $settings (SessionStart + Stop hooks)"
  elif grep -q 'a2a.sh' "$settings"; then
    say "keep $settings (a2a hooks present)"
  elif command -v jq >/dev/null; then
    jq --argjson add "$(claude_hooks_json)" '
      .hooks.SessionStart = ((.hooks.SessionStart // []) + $add.hooks.SessionStart) |
      .hooks.Stop         = ((.hooks.Stop // [])         + $add.hooks.Stop)' "$settings" > "$settings.tmp" \
      && mv "$settings.tmp" "$settings" && say "merged a2a hooks into $settings"
  else
    warn "$settings exists and jq isn't installed; merge these hooks by hand:"; claude_hooks_json >&2
  fi

  if [ "$clean_index" = 1 ]; then
    git add -A -- AGENTS.md CLAUDE.md "$A2A_DIR" scripts/a2a.sh .githooks .claude/settings.json
    git add -u -- . 2>/dev/null || true   # picks up the legacy moves
    if ! git diff --cached --quiet; then
      git commit -q -m "chore(a2a): bootstrap A2A handoff kit v$A2A_VERSION" && say "committed. Push it, then run Prompt 1 in any agent."
    fi
  else
    warn "you had staged changes, so nothing was committed. Review and commit the a2a files yourself."
  fi
}

# prints why the handoff is stale and returns 0; returns 1 if current.  $1=commits → ignore the working tree
stale_reason() {
  local last n commits
  last="$(git log -1 --format=%H -- "$A2A_DIR/STATE.md" 2>/dev/null || true)"
  if [ -z "$last" ] && [ -f "$A2A_DIR/STATE.md" ] \
     && ! git ls-files --error-unmatch "$A2A_DIR/STATE.md" >/dev/null 2>&1; then
    commits="$(git rev-list --count --all 2>/dev/null || echo 0)"
    if [ "${commits:-0}" -gt 0 ]; then
      echo "a2a/STATE.md was never committed (a2a/ gitignored or scaffold not committed?) — the freshness guard has no anchor"; return 0
    fi
  fi
  if [ -n "$last" ]; then
    n="$(git log --format=%H "$last"..HEAD -- . ":(exclude)$A2A_DIR" 2>/dev/null | wc -l | tr -d ' ')"
    if [ "${n:-0}" -gt 0 ]; then echo "$n commit(s) changed code after a2a/STATE.md was last updated"; return 0; fi
  fi
  if [ "${1:-}" != "commits" ] && [ -n "$(git status --porcelain -- . ":(exclude)$A2A_DIR")" ]; then
    # A dirty STATE.md no longer silences this: an updated-but-uncommitted handoff
    # still needs a commit before the turn (or the handoff) is done.
    if [ -n "$(git status --porcelain -- "$A2A_DIR/STATE.md")" ]; then
      echo "uncommitted code changes and an uncommitted a2a/STATE.md — commit them"; return 0
    fi
    echo "uncommitted code changes but a2a/STATE.md hasn't been updated"; return 0
  fi
  return 1
}

cmd_check() {
  local mode="${1:-manual}" input="" why
  in_repo || exit 0
  cd "$(repo_root)"
  [ -f "$A2A_DIR/STATE.md" ] || exit 0
  if [ "$mode" = "stop" ]; then
    input="$(cat || true)"
    # Claude already continued once because of this hook; let it stop (pre-push still guards the push)
    printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
  fi
  if why="$(stale_reason "$([ "$mode" = prepush ] && echo commits || true)")"; then
    case "$mode" in
      stop)    echo "A2A handoff is stale: $why. Overwrite a2a/STATE.md, append a2a/LOG.md (and TASKS/ISSUES/DECISIONS if touched), then commit and push before finishing." >&2; exit 2 ;;
      prepush) echo "A2A: push blocked: $why. Update a2a/STATE.md and a2a/LOG.md, commit, then push." >&2; exit 1 ;;
      *)       warn "stale: $why"; exit 1 ;;
    esac
  fi
  [ "$mode" = "manual" ] && say "handoff is current"
  exit 0
}

cmd_start() {
  in_repo || exit 0
  cd "$(repo_root)"
  local br up behind ahead
  br="$(branch)"
  GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes" timeout 10 git fetch --quiet 2>/dev/null || true
  echo "## A2A session context — $(host), $(ts)"
  echo "Branch: $br"
  if up="$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null)"; then
    behind="$(git rev-list --count HEAD.."$up" 2>/dev/null || echo 0)"
    ahead="$(git rev-list --count "$up"..HEAD 2>/dev/null || echo 0)"
    echo "Upstream: $up (ahead $ahead, behind $behind)"
    [ "$behind" -gt 0 ] && echo "WARNING: $behind commit(s) behind upstream. Run \`git pull --rebase\` before editing."
  fi
  if [ -n "$(git status --porcelain)" ]; then echo "Uncommitted:"; git status --short | head -20; fi
  if [ -f "$A2A_DIR/STATE.md" ]; then
    echo; echo "### a2a/STATE.md"; cat "$A2A_DIR/STATE.md"
  else
    echo "No a2a/STATE.md in this repo. Suggest running \`a2a init\` if this is ongoing work."
  fi
  return 0
}

cmd_resume() {
  in_repo || die "not inside a git repo"
  cd "$(repo_root)"
  git pull --rebase --autostash || die "pull failed; sort it out before starting an agent"
  [ -f .githooks/pre-push ] && cmd_hooks
  cmd_start
  local want; want="$(grep -m1 -oP '^Branch:\s*\K[^ |]+' "$A2A_DIR/STATE.md" 2>/dev/null || true)"
  if [ -n "$want" ] && [ "$want" != "$(branch)" ]; then
    warn "STATE.md says branch '$want', you're on '$(branch)':  git switch $want && git pull"
  fi
}

cmd_handoff() {
  in_repo || die "not inside a git repo"
  cd "$(repo_root)"
  local br why skip=0 a
  br="$(branch)"
  if why="$(stale_reason)"; then
    warn "$why"
    [ -t 0 ] || die "STATE.md is stale. Ask the agent to update it first (refusing non-interactive WIP push)."
    read -rp "Better: ask your agent to update a2a/STATE.md first. Push WIP anyway? [y/N] " a
    [[ "$a" =~ ^[Yy]$ ]] || exit 1
    skip=1
  fi
  if [ $skip = 1 ]; then
    # Mark STATE.md instead of skipping hooks: the marker commit becomes the newest
    # STATE update, so the pre-push guard passes without --no-verify.
    printf '\n## WIP handoff marker (%s)\nPushed with code changes after the last real STATE update, at FB'"'"'s explicit confirmation. Next agent: rebuild this file from `git log` and the diff before doing anything else.\n' "$(ts)" >> "$A2A_DIR/STATE.md"
  fi
  [ -f "$A2A_DIR/LOG.md" ] && printf -- '- %s | FB (manual handoff) | %s | %s | WIP handoff%s | -\n' \
      "$(ts)" "$(host)" "$br" "$([ $skip = 1 ] && echo ', STATE.md WIP-marked' || true)" >> "$A2A_DIR/LOG.md"
  git add -A
  git diff --cached --quiet || git commit -q -m "wip(a2a): handoff from $(host)"
  git push -u origin "$br"
  say "pushed $br. On the other machine: a2a resume"
}

cmd_doctor() {
  local fix_mode=false
  if [[ "${1:-}" == "--fix" ]]; then
    fix_mode=true
  fi

  local f
  echo "Global rules:"
  for f in "$CLAUDE_HOME/CLAUDE.md" "$CODEX_HOME/AGENTS.md" "$GEMINI_HOME/GEMINI.md"; do
    if [ -L "$f" ]; then echo "  ok  $f -> $(readlink "$f")"
    elif [ -f "$f" ]; then echo "  !!  $f is a plain file, not linked to GLOBAL.md"
    else echo "  --  $f missing (run a2a install)"; fi
  done
  f="$HERMES_HOME/SOUL.md"
  if [ -f "$f" ] && grep -q "$MARKER" "$f"; then
    if [ "$A2A_HOME/GLOBAL.md" -nt "$f" ]; then 
      echo "  !!  $f older than GLOBAL.md (run a2a soul)"
      if [ "$fix_mode" = true ]; then
        cmd_soul
      fi
    else echo "  ok  $f"; fi
  else echo "  --  $f has no A2A section (run a2a soul)"; fi
  command -v a2a >/dev/null && echo "  ok  a2a on PATH" || echo "  !!  a2a not on PATH"

  in_repo || return 0
  cd "$(repo_root)"
  echo "Repo $(basename "$(pwd)"):"
  if [ -f AGENTS.md ]; then
    local sz; sz="$(wc -c < AGENTS.md | tr -d ' ')"
    if   [ "$sz" -gt 12000 ]; then echo "  !!  AGENTS.md is $sz chars (Antigravity truncates around 12k)"
    elif [ "$sz" -gt 8000 ];  then echo "  ~~  AGENTS.md is $sz chars (aim for under 8k)"
    else echo "  ok  AGENTS.md ($sz chars)"; fi
  else echo "  !!  no AGENTS.md"; fi
  grep -qs '^@AGENTS.md' CLAUDE.md && echo "  ok  CLAUDE.md imports AGENTS.md" || echo "  !!  CLAUDE.md doesn't import AGENTS.md"
  for f in .hermes.md HERMES.md AGENTS.override.md; do [ -e "$f" ] && echo "  !!  $f shadows AGENTS.md in Hermes"; done
  [ -e GEMINI.md ] && echo "  !!  GEMINI.md overrides AGENTS.md in Antigravity"
  [ "$(git config --get core.hooksPath || true)" = ".githooks" ] && echo "  ok  pre-push guard active" || { echo "  !!  pre-push guard inactive in this clone (a2a resume or a2a init)"; if [ "$fix_mode" = true ]; then cmd_hooks; fi; }
  grep -qs 'a2a.sh' .claude/settings.json && echo "  ok  Claude hooks" || { echo "  !!  Claude hooks missing"; if [ "$fix_mode" = true ]; then cmd_install; fi; }
  [ -f "$A2A_DIR/STATE.md" ] && echo "  ok  a2a/STATE.md" || { echo "  !!  no a2a/STATE.md"; if [ "$fix_mode" = true ]; then cmd_init; fi; }
  [ -d "$A2A_DIR/legacy" ] && echo "  ~~  a2a/legacy/ still present (run the bootstrap prompt)"
  local why; if why="$(stale_reason)"; then echo "  ~~  handoff stale: $why"; if [ "$fix_mode" = true ]; then echo "  → Run 'a2a handoff' to fix"; fi; else echo "  ok  handoff current"; fi
  return 0
}

usage() { grep -E '^# (a2a\.sh|  a2a )' "$SELF" | sed 's/^# \{0,1\}//'; }

case "${1:-help}" in
  install) cmd_install ;;
  init)    cmd_init ;;
  hooks)   cd "$(repo_root)" && cmd_hooks ;;
  check)   shift; cmd_check "${1:-manual}" ;;
  start)   cmd_start ;;
  resume)  cmd_resume ;;
  handoff) cmd_handoff ;;
  soul)    cmd_soul ;;
  doctor)  shift; cmd_doctor "$@" ;;
  check-all) shift; "$SELF" check "$@" && "$(repo_root)/scripts/a2a-check" "$@" ;;
  version) echo "a2a $A2A_VERSION" ;;
  *)       usage ;;
esac
