#!/bin/bash

<#
.SYNOPSIS
    Network Watchdog v1.1 - Webhook Edition.
.DESCRIPTION
    Skanner det lokale nettverket via arp-scan og validerer enheter mot en hvitliste.
    Sender umiddelbart varsel via Webhook ved deteksjon av ukjente MAC-adresser.
.NOTES
    Sørg for at config.conf inneholder en gyldig WEBHOOK_URL.
#>

# --- KONFIGURASJON ---
WHITELIST="whitelist.txt"
LOGFILE="logs/watchdog.log"
CONFIG_FILE="config.conf"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Sjekk om konfigurasjonsfilen eksisterer
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "FEIL: $CONFIG_FILE mangler. Opprett filen med WEBHOOK_URL."
    exit 1
fi

# --- FUNKSJONER ---

<#
.SYNOPSIS
    Sender JSON-data til spesifisert Webhook.
.PARAMETER 1
    Meldingen som skal sendes.
#>
send_webhook() {
    local message=$1
    if [[ -n "$WEBHOOK_URL" && "$WEBHOOK_URL" != "lim_inn_din_url_her" ]]; then
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"$message\"}" \
             "$WEBHOOK_URL" &>/dev/null
    fi
}

# --- HOVEDLOGIKK ---

# Verifiser at nødvendige verktøy er installert
if ! command -v arp-scan &> /dev/null; then
    echo "FEIL: arp-scan er ikke installert. Kjør: sudo apt install arp-scan -y"
    exit 1
fi

echo "[$TIMESTAMP] Starter nettverksskanning..."

# Utfør skanning og filtrer ut MAC-adresser
sudo arp-scan --localnet | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' > current_scan.tmp

# Prosesser hver funnet enhet
while read -r line; do
    MAC=$(echo "$line" | awk '{print $2}')
    IP=$(echo "$line" | awk '{print $1}')

    # Sjekk mot hvitliste (ignorerer store/små bokstaver)
    if ! grep -qi "$MAC" "$WHITELIST"; then
        ALERT_MSG="⚠️ **Sikkerhetsvarsel**: Ukjent enhet detektert! IP: $IP | MAC: $MAC"
        echo " [!] ADVARSEL: Ukjent enhet funnet! IP: $IP - MAC: $MAC" | tee -a "$LOGFILE"
        
        # Trigger varsling
        send_webhook "$ALERT_MSG"
    else
        echo " [OK] Kjent enhet: $IP ($MAC)"
    fi
done < current_scan.tmp

# Rydd opp i midlertidige filer
if [ -f "current_scan.tmp" ]; then
    rm current_scan.tmp
fi