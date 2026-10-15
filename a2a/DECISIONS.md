# DECISIONS

One entry per non-obvious choice. Agents: don't reverse these without FB's agreement.

---

## D-001 — Use proot-distro instead of direct Termux (2026-07, inherited)

**Context:** Hermes Agent and its Python dependencies require a full Linux userspace. Termux alone cannot run many packages.

**Decision:** Run Hermes Agent inside proot-distro Ubuntu, not directly in Termux.

**Rejected:** Direct Termux installation with sysconfig hacks (tried in early versions, fragile).

**Consequences:** Adds complexity (nested environments), but provides compatibility. Launchers must transparently enter Ubuntu.

**Related:** ARCH-001, BUG-002, BUG-005

---

## D-002 — Use uv for Python version management (2026-07)

**Context:** Ubuntu 25.04 ships Python 3.14 which is incompatible with Hermes (requires <3.14). apt pinning is fragile.

**Decision:** Use Astral's `uv` to manage Python versions. `uv venv --python ">=3.11,<3.14"` automatically downloads a compatible version.

**Rejected:** `apt install python3.11` (not available on all Ubuntu versions), deadsnakes PPA (adds complexity), pyenv (slow, complex).

**Consequences:** Adds dependency on `uv`, but eliminates fragile sysconfig hacks and apt version pinning. Works on any Ubuntu version.

**Related:** ARCH-002, BUG-003, BUG-005

---

## D-003 — Monolithic installer with inline heredocs (2026-07)

**Context:** Need a one-liner `curl | bash` installation pattern for user convenience.

**Decision:** `nous_agent.sh` contains all launcher scripts as inline heredocs, deployed to `$PREFIX/bin/` during installation. Standalone copies in `scripts/` are refreshed by `hermes-update`.

**Rejected:** Separate installer + separate script downloads (adds failure points), single script without launchers (no user-facing commands).

**Consequences:** Changes to launchers require updating both `nous_agent.sh` and `scripts/` copies. `hermes-update` synchronizes them from GitHub.

**Related:** ARCH-003, BUG-004

---

## D-004 — Gateway launcher does NOT use exec on proot-distro (2026-08)

**Context:** Gateway needs to send Telegram "offline" notification on exit (Ctrl+C, crash, normal exit). EXIT trap must fire.

**Decision:** Gateway pattern: `proot-distro login ubuntu -- bash -c '...' -- "$@" || GATEWAY_EXIT=$?` (no `exec`). Main launcher uses `exec` for efficiency.

**Rejected:** Using `exec` everywhere (breaks trap), running trap inside Ubuntu (adds complexity, separate process).

**Consequences:** Slightly different pattern for gateway vs main launcher. Must remember this distinction when editing.

**Related:** ARCH-003, BUG-004

---

## D-005 — Filesystem check for Ubuntu detection (2026-08)

**Context:** `proot-distro list | grep` parsing is fragile — output format can change, locale issues, pipe failures.

**Decision:** Check for directory existence: `[ -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/ubuntu" ]`

**Rejected:** Parsing `proot-distro list` output, trying to run a command inside Ubuntu (slow, false negatives).

**Consequences:** POSIX-compatible, fast, deterministic. Only reliable method.

**Related:** ARCH-001, BUG-002

---

## D-006 — No CI/CD pipeline (intentional, 2026-09)

**Context:** Project is shell-script-only installer. Testing requires physical Android device with Termux.

**Decision:** No GitHub Actions CI. Manual `bash -n` syntax check + on-device testing.

**Rejected:** GitHub Actions with shellcheck (doesn't catch runtime issues), emulated Android CI (complex, slow).

**Consequences:** PTI-001 tracks adding CI for syntax check + permissions + secrets. On-device testing still required for real validation.

**Related:** PTI-001

---

## D-007 — Version pinning in installer (HERMES_TAG) (2026-07)

**Context:** Users need stable, reproducible installs. `main` branch may have breaking changes.

**Decision:** Pin to specific release tag in `nous_agent.sh` (default). Provide `--edge` flag for main branch tracking. `hermes-update` auto-discovers latest tag.

**Rejected:** Always track main (unstable), no version pinning (users get random versions).

**Consequences:** Must update `HERMES_TAG` in `nous_agent.sh` for each release. `hermes-update` handles this for existing users.

**Related:** ARCH-003

---

## D-008 — Telegram notifications optional, not required (2026-08)

**Context:** Some users want notifications, others don't. Bot setup is extra friction.

**Decision:** Gateway runs without notifications if env vars not set. Shows clear instructions if API key missing.

**Rejected:** Require Telegram for gateway (excludes users), hardcode notifications (privacy/security issue).

**Consequences:** Gateway works for everyone. Notifications are opt-in via `HERMES_TELEGRAM_BOT_TOKEN` + `HERMES_TELEGRAM_CHAT_ID`.

**Related:** A2A-How2.md (environment variables section)

---

## D-009 — A2A Kit migration (2026-10-15)

**Context:** Legacy A2A-*.md files scattered at repo root. New A2A Kit provides unified structure with a2a/ folder, a2a.sh tool, and enforced handoff.

**Decision:** Run `a2a init` to migrate. Old files moved to `a2a/legacy/`, new structure created. Legacy files to be deleted after verification.

**Rejected:** Keep old structure (inconsistent with other repos), manual migration (error-prone).

**Consequences:** New handoff protocol enforced by git pre-push hook and Claude hooks. All agents use a2a/STATE.md as single source of truth.

**Related:** A2A-KIT.md, A2A-PROMPT.md, a2a.sh

---

## D-010 — No BUSINESS.md (this repo doesn't sell anything)

**Context:** A2A Kit creates BUSINESS.md only for repos that sell products.

**Decision:** This is a free open-source installer. No BUSINESS.md created.

**Rejected:** Create empty BUSINESS.md (noise).

**Consequences:** WHAT.md explicitly states "No" to selling products. BUSINESS.md absent.

**Related:** WHAT.md