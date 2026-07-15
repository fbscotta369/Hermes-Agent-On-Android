<div align="center">
<img width="1145" height="196" alt="hermesbanner" src="https://github.com/user-attachments/assets/68e4a2a7-74d2-4089-9e5f-6f0a46fe54f5" />

<img width="150" alt="AIIA-Labs" src="assets/aiia-labs-logo.png" />

# *☤ Hermes Agent for Android (Termux)*

### *Run a Self-Evolving AI Assistant on Your Phone*

[![License: MIT](https://img.shields.io/badge/License-MIT-9146ff.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Termux](https://img.shields.io/badge/Termux-Android-ff6b6b.svg?style=for-the-badge)](https://termux.com/)
[![Version](https://img.shields.io/badge/version-v0.18.2-4ecdc4.svg?style=for-the-badge)](https://github.com/NousResearch/hermes-agent)

**Transform your Android device into a powerful, learning AI assistant**
</div>

## ✨ What is Hermes Agent?

> **Hermes Agent** is an open-source, self-evolving AI framework developed by [Nous Research](https://github.com/NousResearch/hermes-agent). It's like having **Jarvis in your pocket** — an AI that learns, adapts, and grows smarter with every interaction.

<div align="center">

| 🧠 Self-Learning | 🔄 Cross-Platform | 💾 Persistent Memory | 🛠️ 70+ Tools |
|:----------------:|:------------------:|:-------------------:|:-------------:|
| Gets smarter over time | Works across 16+ apps | Remembers your preferences | Execute complex tasks |

</div>

---

## ⏱️ Installation takes ~5-10 minutes — Grab a coffee! ☕

---

# 🚀 **One-Command Installation**

### **Copy and paste this in Termux:**

```bash
curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/nous_agent.sh | bash
```

**That's it.** The installer:
1. ✅ Checks your Android version, storage, and internet connectivity
2. ✅ Installs proot-distro + Ubuntu (if not already present)
3. ✅ Clones the latest stable Hermes Agent
4. ✅ Sets up the Python virtual environment
5. ✅ Installs `hermes`, `hermes-setup`, `hermes-update` commands for Termux

### 🔧 After install, just type:

```bash
hermes setup      # First-time configuration (once)
hermes            # Start the agent
```

**No more 4-step ritual.** The `hermes` command automatically enters Ubuntu, activates the virtual environment, and passes your arguments through.

---

## 🎛️ Installation Options

### Stable vs. Edge

```bash
# Default — installs the pinned stable release (v2026.7.7.2)
curl -fsSL .../nous_agent.sh | bash

# Edge — tracks the main branch (latest features)
curl -fsSL .../nous_agent.sh | bash -s -- --edge

# Specific tag
curl -fsSL .../nous_agent.sh | bash -s -- --tag v2026.7.7.2
```

### Direct Termux Install (Alternative)

If you prefer running Hermes directly in Termux without proot-distro:

```bash
curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/install.sh | bash
```

---

## 📦 Commands Available After Installation

| Command | Description |
|---------|-------------|
| `hermes` | Start the agent (auto-enters Ubuntu + venv) |
| `hermes setup` | First-time configuration wizard |
| `hermes gateway` | Start the gateway (with Telegram notifications) |
| `hermes-doctor` | Run diagnostics (API keys, Python, connectivity) |
| `hermes-update` | Update to the latest version |
| `hermes-update --edge` | Update to latest main branch |
| `hermes-setup` | Alias for `hermes setup` |

---

## 🛠️ Manual Installation (if you prefer step-by-step)

```bash
pkg install git
git clone https://github.com/fbscotta369/Hermes-Agent-On-Android.git
cd Hermes-Agent-On-Android
chmod +x nous_agent.sh
./nous_agent.sh
```

---

## 📁 Project Structure

```
Hermes-Agent-On-Android/
├── nous_agent.sh          # 🏆 One-command installer (recommended)
├── install.sh             # Direct Termux install (alternative)
├── scripts/
│   ├── hermes             # Launcher — chains Termux → Ubuntu → venv
│   ├── hermes-setup       # One-shot setup command
│   ├── hermes-gateway     # Gateway + Telegram notifications + error diagnostics
│   ├── hermes-doctor      # Diagnostic tool (API keys, Python, connectivity)
│   ├── hermes-update      # Update to latest version
│   └── uninstall.sh       # Clean removal script
├── assets/
│   └── aiia-labs-logo.png # AIIA-Labs branding
├── agent_install.sh       # ⚠️ Legacy
├── hermes_install.sh      # ⚠️ Legacy
├── proot_install.sh       # ⚠️ Legacy
├── nous_hermes_agent_install.sh  # ⚠️ Legacy
├── .gitignore
└── README.md
```

---

## ⚙️ System Requirements

| Requirement | Minimum | Recommended |
|:------------|:-------:|-------------:|
| **Android Version** | 11 | 13, 14, or 15 |
| **Storage Space** | 3 GB | 5 GB+ |
| **RAM** | 2 GB | 4 GB+ |
| **Internet** | Required | Fast connection |
| **Termux** | Latest | Latest from F-Droid |

---

## 🌍 Why Run Hermes on Android?

| Benefit | Description |
|:--------|:------------|
| **📱 Portable AI** | Your assistant goes everywhere |
| **🔒 Privacy** | Runs locally on your device |
| **💰 Cost-effective** | No server hosting fees |
| **⚡ Low latency** | Direct execution |
| **🔄 Always available** | Works offline (with local models) |

---

## 🎛️ AI Model Freedom

Compatible with 200+ AI models including:

- OpenAI (GPT-4, GPT-3.5)
- Anthropic (Claude)
- Google (Gemini)
- DeepSeek
- Alibaba (Qwen)
- Zhipu (GLM)
- Local models via Ollama

## 🦙 Running Local Models with [Ollama](https://ollama.com)

### Install Ollama on Termux:
```bash
pkg install ollama
ollama serve
```

### Pull & Run Models
```bash
ollama run gemma4:31b-cloud
```

---

## 🔄 Updating

```bash
# Update to latest stable tag
hermes-update

# Update to latest main branch (bleeding edge)
hermes-update --edge
```

## 🗑️ Uninstalling

```bash
# From inside the repo:
bash scripts/uninstall.sh
```

---

## 📱 Telegram Notifications (Optional)

Get notified on your phone when the Hermes Agent Gateway starts or stops.

### 1. Create a Telegram Bot

1. Open Telegram and message **[@BotFather](https://t.me/BotFather)**
2. Send `/newbot` and follow the prompts
3. Copy the **bot token** (looks like `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

### 2. Get Your Chat ID

1. Open your new bot in Telegram and send any message
2. Visit `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates` in a browser
3. Find `"chat":{"id":` — that number is your **chat ID**

### 3. Set Environment Variables

Add these to your Termux `~/.bashrc`:

```bash
export HERMES_TELEGRAM_BOT_TOKEN="your-bot-token-here"
export HERMES_TELEGRAM_CHAT_ID="your-chat-id-here"
```

Then reload:

```bash
source ~/.bashrc
```

### 4. Start the Gateway

```bash
hermes-gateway
```

You'll receive:
- **"Hermes Agent Gateway online ;-)"** — when the gateway starts
- **"Hermes Agent Gateway offline :-("** — when it stops (Ctrl+C, kill, or crash)

> 💡 If the env vars aren't set, the gateway still works — just without notifications.

---

## 🔧 Troubleshooting

### "Provider authentication failed" / "Check configured credentials"

This means your API key is invalid, expired, or not set. Fix it:

```bash
# Run the diagnostic tool — it checks everything
hermes-doctor
```

**Common causes:**

| Error | Fix |
|-------|-----|
| No API key set | `export GOOGLE_API_KEY="your-key"` in `~/.bashrc` |
| Key expired | Generate a new key at your provider's dashboard |
| Key format wrong | Gemini keys start with `AIza`, OpenAI with `sk-`, Anthropic with `sk-ant-` |
| Free tier quota exceeded | Upgrade plan or wait for quota reset |

**For Google Gemini specifically:**
1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Generate a **new API key**
3. Ensure **Generative Language API** is enabled in your Google Cloud project
4. Set it: `export GOOGLE_API_KEY="your-new-key"`
5. Restart: `hermes gateway`

### Gateway exits immediately

```bash
# Check what's wrong
hermes-doctor

# Debug with verbose logs
proot-distro login ubuntu
cd ~/hermes-agent && source venv/bin/activate
hermes gateway --log-level debug
```

### "Python 3.14 not in <3.14" error

Re-run the installer — it uses `uv` to install a compatible Python version:

```bash
curl -fsSL https://raw.githubusercontent.com/fbscotta369/Hermes-Agent-On-Android/main/nous_agent.sh | bash
```

---

## 🙏 Acknowledgments

- **Nous Research** — For creating the amazing Hermes Agent
- **AbuZar-Ansarii** — Original Android packaging work
- **Termux Team** — For making Android development possible
- **Open Source Community** — For the countless tools and libraries
- **You** — For using and supporting this project! ❤️

<div align="center">

## **⭐ If this helped you, give it a star! ⭐**
</div>
