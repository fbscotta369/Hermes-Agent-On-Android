#!/data/data/com.termux/files/usr/bin/bash
# lib/telegram.sh — Enhanced Telegram notification helpers

# Send Telegram message with optional formatting
# Usage: send_telegram "text" [parse_mode] [disable_web_page_preview]
send_telegram() {
    local text="$1"
    local parse_mode="${2:-HTML}"
    local disable_preview="${3:-true}"
    
    [ -z "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] && return 0
    [ -z "${HERMES_TELEGRAM_CHAT_ID:-}" ] && return 0
    
    curl -s -X POST "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${HERMES_TELEGRAM_CHAT_ID}" \
        -d text="$text" \
        -d parse_mode="$parse_mode" \
        -d disable_web_page_preview="$disable_preview" \
        --max-time 10 >/dev/null 2>&1 || true
}

# Send formatted Telegram message with markdown
send_telegram_md() {
    send_telegram "$1" "MarkdownV2" "true"
}

# Send Telegram message with inline keyboard
# Usage: send_telegram_keyboard "text" "button1_text|button1_url" "button2_text|button2_url" ...
send_telegram_keyboard() {
    local text="$1"
    shift
    
    [ -z "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] && return 0
    [ -z "${HERMES_TELEGRAM_CHAT_ID:-}" ] && return 0
    
    # Build inline keyboard JSON
    local keyboard='{"inline_keyboard":['
    local first=true
    for btn in "$@"; do
        local btn_text="${btn%%|*}"
        local btn_url="${btn#*|}"
        if [ "$first" = true ]; then
            first=false
        else
            keyboard+=','
        fi
        keyboard+='[{"text":"'"$btn_text"'","url":"'"$btn_url"'"}]'
    done
    keyboard+=']}'
    
    curl -s -X POST "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${HERMES_TELEGRAM_CHAT_ID}" \
        -d text="$text" \
        -d parse_mode="HTML" \
        -d reply_markup="$keyboard" \
        --max-time 10 >/dev/null 2>&1 || true
}

# Send gateway online notification
notify_gateway_online() {
    local provider="Unknown"
    [ -n "${GOOGLE_API_KEY:-}" ] && provider="Google Gemini"
    [ -n "${GEMINI_API_KEY:-}" ] && provider="Google Gemini"
    [ -n "${OPENAI_API_KEY:-}" ] && provider="OpenAI"
    [ -n "${ANTHROPIC_API_KEY:-}" ] && provider="Anthropic"
    
    local version
    version=$(get_current_hermes_version 2>/dev/null || echo "unknown")
    
    send_telegram "🤖 <b>Hermes Agent Gateway Online</b>
<i>Provider:</i> ${provider}
<i>Version:</i> ${version}
<i>Time:</i> $(date '+%Y-%m-%d %H:%M %Z')"
}

# Send gateway offline notification
notify_gateway_offline() {
    local exit_code="${1:-0}"
    local reason="${2:-}"
    
    if [ "$exit_code" -eq 0 ]; then
        send_telegram "😴 <b>Hermes Agent Gateway Offline</b>
<i>Status:</i> Clean shutdown
<i>Time:</i> $(date '+%Y-%m-%d %H:%M %Z')"
    else
        send_telegram "💥 <b>Hermes Agent Gateway Crashed</b>
<i>Exit code:</i> ${exit_code}
<i>Reason:</i> ${reason:-Unknown}
<i>Time:</i> $(date '+%Y-%m-%d %H:%M %Z')"
    fi
}

# Send error notification with actionable buttons
notify_error() {
    local error_msg="$1"
    local docs_url="https://github.com/fbscotta369/Hermes-Agent-On-Android"
    
    send_telegram_keyboard \
        "⚠️ <b>Hermes Agent Error</b>
<i>${error_msg}</i>" \
        "📖 View Docs|${docs_url}" \
        "🔧 Run Doctor|${docs_url}/blob/main/scripts/hermes-doctor"
}

# Send update notification
notify_update() {
    local old_version="$1"
    local new_version="$2"
    local mode="${3:-stable}"
    
    send_telegram "🔄 <b>Hermes Agent Updated</b>
<i>From:</i> ${old_version}
<i>To:</i> ${new_version} (${mode})
<i>Time:</i> $(date '+%Y-%m-%d %H:%M %Z')"
}

# Test Telegram configuration
test_telegram() {
    if [ -z "${HERMES_TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${HERMES_TELEGRAM_CHAT_ID:-}" ]; then
        return 1
    fi
    
    local result
    result=$(curl -s --max-time 10 "https://api.telegram.org/bot${HERMES_TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null)
    if echo "$result" | grep -q '"ok":true'; then
        local bot_name
        bot_name=$(echo "$result" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        echo "@${bot_name}"
        return 0
    fi
    return 1
}