# A2A-WHAT — What Is This Repo?

## One-Sentence Answer

A shell-script installer that packages the Nous Research Hermes Agent for
running on Android devices via Termux + proot-distro Ubuntu.

## Slightly Longer Answer

This repository contains:
- `nous_agent.sh` — a one-command installer for Android/Termux
- `install.sh` — an alternative direct-Termux installer
- `scripts/hermes*` — launcher scripts that transparently enter Ubuntu and run
the Hermes Agent Python package

It does NOT contain the Hermes Agent application itself. That lives at
`NousResearch/hermes-agent` and is cloned at install time.

## Who Uses This

People who want to run a self-evolving AI assistant on their Android phone.

## Canonical Docs

- User guide: `README.md`
- Architecture: `A2A-ArchMap.md`
- Product: `A2A-Product.md`
