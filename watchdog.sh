#!/bin/bash

<#
.SYNOPSIS
    Network Watchdog v1.2 - Enhanced Edition.
.DESCRIPTION
    Skanner det lokale nettverket via arp-scan og validerer enheter mot en hvitliste.
    Sender varsel via Webhook ved ukjente MAC-adresser og identifiserer produsent.
.NOTES
    Sørg for at config.conf inneholder en gyldig WEBHOOK_URL.
#>

# --- KONFIGURASJON ---
WHITELIST="whitelist.txt"
LOGFILE="logs/watchdog.log"
CONFIG_FILE="config.conf"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Farger for terminal-output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Sjekk om konfigurasjonsfilen eksisterer
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${RED}FEIL: $CONFIG_FILE mangler. Opprett filen med WEBHOOK_URL.${NC}"
    exit 1
fi

# Om hvitlisten eksisterer
if [ ! -f "$WHITELIST" ]; then
    echo -e "${YELLOW}ADVARSEL: $WHITELIST mangler. Oppretter tom hvitliste.${NC}"
    touch "$WHITELIST"
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
    echo -e "${RED}FEIL: arp-scan er ikke installert. Kjør: sudo apt install arp-scan -y${NC}"
    exit 1
fi

echo -e "${NC}[$TIMESTAMP] Starter nettverksskanning...${NC}"

# Utfør skanning og behold rådata for å trekke ut produsent (Vendor)
sudo arp-scan --localnet | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' > current_scan.tmp

# Prosesser hver funnet enhet
while read -r line; do
    IP=$(echo "$line" | awk '{print $1}')
    MAC=$(echo "$line" | awk '{print $2}')
    # Trekker ut produsentnavn (alt etter MAC-adressen på linjen)
    VENDOR=$(echo "$line" | cut -f3-)

    # Sjekk mot hvitliste (ignorerer store/små bokstaver)
    if ! grep -qi "$MAC" "$WHITELIST"; then
        ALERT_MSG="⚠️ **Sikkerhetsvarsel**: Ukjent enhet detektert! IP: $IP | MAC: $MAC | Produsent: $VENDOR"
        
        echo -e "${RED} [!] ADVARSEL: Ukjent enhet funnet! IP: $IP - MAC: $MAC ($VENDOR)${NC}" | tee -a "$LOGFILE"
        
        # Trigger varsling
        send_webhook "$ALERT_MSG"
    else
        echo -e "${GREEN} [OK] Kjent enhet: $IP ($MAC) - $VENDOR${NC}"
    fi
done < current_scan.tmp

# Rydd opp i midlertidige filer
if [ -f "current_scan.tmp" ]; then
    rm current_scan.tmp
fi