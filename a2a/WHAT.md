# WHAT

Product and business facts. Only if this repo is a product, website or app; otherwise write N/A once and stop.
Agents: answer only what the code or FB proves. Anything else stays UNKNOWN until FB confirms.

1. **URL of this repo / website / app?**
   https://github.com/fbscotta369/Hermes-Agent-On-Android

2. **Does it sell products? Which ones?**
   No. This is a free, open-source installer for the Nous Research Hermes Agent. It does not sell anything.

3. **Buyer persona and/or target audience?**
   Android users who want to run a self-evolving AI assistant (Hermes Agent) on their phone via Termux. Technical users comfortable with command-line tools.

4. **Payment options and payment gateway?**
   N/A — no payment, no monetisation.

5. **Payment process?**
   N/A

6. **How is the product delivered to the buyer?**
   N/A — it's a GitHub repository with a one-liner installer. Users run `curl | bash` in Termux.

---

## What Is This Repo?

A shell-script installer that packages the Nous Research Hermes Agent for running on Android devices via Termux + proot-distro Ubuntu.

## What This Is

- `nous_agent.sh` — a one-command installer for Android/Termux
- `install.sh` — an alternative direct-Termux installer
- `scripts/hermes*` — launcher scripts that transparently enter Ubuntu and run the Hermes Agent Python package

## What This Is NOT

- The Hermes Agent application itself (that's `NousResearch/hermes-agent`)
- A general Android app (no APK, no Play Store)
- A hosted service (runs entirely on the user's device)

## Value Proposition

- One-command installation on Android
- Automatic Ubuntu + Python environment setup
- Transparent launcher commands (`hermes`, `hermes-gateway`, etc.)
- Built-in diagnostics (`hermes-doctor`)
- Self-updating (`hermes-update`)

## User Journey

1. User runs `curl | bash` one-liner in Termux
2. Installer sets up Ubuntu + Python + Hermes Agent
3. User types `hermes setup` once
4. User types `hermes` or `hermes gateway` to run
5. User types `hermes-update` to get latest version

## Canonical Docs

- User guide: `README.md`
- Architecture: `a2a/TECHNICAL.md`