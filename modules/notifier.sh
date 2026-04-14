#!/bin/bash

# --- MODUL: NOTIFIER ---
# Håndterer utsending av varsler via Webhooks.

# shellcheck source=/dev/null
[ -f "config.conf" ] && source "config.conf"

send_webhook() {
    local message="$1"
    # Sjekker at URL-en er satt og ikke er standardeksempelet
    if [[ -n "$WEBHOOK_URL" && "$WEBHOOK_URL" != "lim_inn_her" ]]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" "$WEBHOOK_URL" &>/dev/null
    fi
}