#!/bin/bash

# SYNOPSIS: Network Watchdog v1.3 - Professional Edition.
# DESCRIPTION: Skanner nettverk, sender varsler og administrerer hvitliste.
# BRUK: ./watchdog.sh [--add MAC | --show | --help]

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

# Last inn konfigurasjon hvis den eksisterer
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# --- FUNKSJONER ---

# Legger til en MAC-adresse i hvitlisten manuelt
add_to_whitelist() {
    local mac=$1
    if [[ $mac =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]]; then
        if ! grep -qi "$mac" "$WHITELIST"; then
            echo "$mac" >> "$WHITELIST"
            echo -e "${GREEN}Lagt til $mac i hvitlisten.${NC}"
        else
            echo -e "${YELLOW}$mac finnes allerede i hvitlisten.${NC}"
        fi
    else
        echo -e "${RED}Feil: Ugyldig MAC-adresse format. (Eks: AA:BB:CC:DD:EE:FF)${NC}"
    fi
}

# Sender JSON-data til spesifisert Webhook
send_webhook() {
    local message=$1
    if [[ -n "$WEBHOOK_URL" && "$WEBHOOK_URL" != "lim_inn_din_url_her" ]]; then
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"$message\"}" \
             "$WEBHOOK_URL" &>/dev/null
    fi
}

# --- ARGUMENT-HÅNDTERING (CLI) ---

if [[ "$1" == "--add" ]]; then
    add_to_whitelist "$2"
    exit 0
elif [[ "$1" == "--show" ]]; then
    echo -e "${BLUE}--- Innhold i hvitliste ---${NC}"
    cat "$WHITELIST"
    exit 0
elif [[ "$1" == "--help" ]]; then
    echo "Bruk: ./watchdog.sh [VALG]"
    echo "--add [MAC]  Legg til en adresse i hvitlisten"
    echo "--show       Vis gjeldende hvitliste"
    echo "--help       Vis denne menyen"
    exit 0
fi

# --- HOVEDLOGIKK ---

# Verifiser at hvitliste-filen eksisterer
if [ ! -f "$WHITELIST" ]; then
    touch "$WHITELIST"
fi

# Verifiser at arp-scan er installert
if ! command -v arp-scan &> /dev/null; then
    echo -e "${RED}FEIL: arp-scan er ikke installert. Kjør ./setup.sh${NC}"
    exit 1
fi

echo -e "${NC}[$TIMESTAMP] Starter nettverksskanning...${NC}"

# Utfør skanning
sudo arp-scan --localnet | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' > current_scan.tmp

FOUND_UNKNOWN=false

# Prosesser hver funnet enhet
while read -r line; do
    IP=$(echo "$line" | awk '{print $1}')
    MAC=$(echo "$line" | awk '{print $2}')
    VENDOR=$(echo "$line" | cut -f3-)

    # Sjekk mot hvitliste
    if ! grep -qi "$MAC" "$WHITELIST"; then
        ALERT_MSG="⚠️ **Sikkerhetsvarsel**: Ukjent enhet detektert! IP: $IP | MAC: $MAC | Produsent: $VENDOR"
        
        echo -e "${RED} [!] ADVARSEL: Ukjent enhet funnet! IP: $IP - MAC: $MAC ($VENDOR)${NC}" | tee -a "$LOGFILE"
        
        send_webhook "$ALERT_MSG"
        FOUND_UNKNOWN=true
    fi
done < current_scan.tmp

# Støydemping: Gir kun bekreftelse hvis ingen ukjente ble funnet
if [ "$FOUND_UNKNOWN" = false ]; then
    echo -e "${GREEN} [OK] Skanning fullført: Ingen ukjente enheter funnet på nettverket.${NC}"
fi

# Rydd opp
rm -f current_scan.tmp