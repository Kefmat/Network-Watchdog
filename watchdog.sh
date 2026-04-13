#!/bin/bash

# --- KONFIGURASJON ---
WHITELIST="whitelist.txt"
LOGFILE="logs/watchdog.log"
CONFIG_FILE="config.conf"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Farger
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Last inn konfigurasjon
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# --- FUNKSJONER ---

# Utfører en lynrask port-skanning av ukjente enheter
scan_ports() {
    local ip=$1
    if command -v nmap &> /dev/null; then
        # Skanner de 20 vanligste portene
        nmap -F --top-ports 20 "$ip" | grep "/tcp" | awk '{print $1}' | paste -sd ", " -
    else
        echo "Nmap ikke installert"
    fi
}

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
        echo -e "${RED}Feil: Ugyldig MAC-format.${NC}"
    fi
}

send_webhook() {
    local message=$1
    if [[ -n "$WEBHOOK_URL" && "$WEBHOOK_URL" != "lim_inn_din_url_her" && "$WEBHOOK_URL" != "lim_inn_her" ]]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" "$WEBHOOK_URL" &>/dev/null
    fi
}

# --- ARGUMENT-HÅNDTERING ---

if [[ "$1" == "--add" ]]; then
    add_to_whitelist "$2"
    exit 0
elif [[ "$1" == "--show" ]]; then
    echo -e "${BLUE}--- Hvitliste ---${NC}"; cat "$WHITELIST"; exit 0
elif [[ "$1" == "--help" ]]; then
    echo "Bruk: ./watchdog.sh [--add MAC | --show | --help]"; exit 0
fi

# --- HOVEDLOGIKK ---

[ ! -f "$WHITELIST" ] && touch "$WHITELIST"

if ! command -v arp-scan &> /dev/null; then
    echo -e "${RED}FEIL: arp-scan mangler. Kjør ./setup.sh${NC}"
    exit 1
fi

echo -e "${NC}[$TIMESTAMP] Starter nettverksskanning...${NC}"
sudo arp-scan --localnet | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' > current_scan.tmp

FOUND_UNKNOWN=false
while read -r line; do
    IP=$(echo "$line" | awk '{print $1}')
    MAC=$(echo "$line" | awk '{print $2}')
    VENDOR=$(echo "$line" | cut -f3-)

    if ! grep -qi "$MAC" "$WHITELIST"; then
        echo -e "${YELLOW}[!] Analyserer ukjent enhet: $IP...${NC}"
        
        # Finn åpne porter
        PORTS=$(scan_ports "$IP")
        [ -z "$PORTS" ] && PORTS="Ingen åpne porter funnet"

        ALERT_MSG="🚨 **SIKKERHETSVARSEL**
**Enhet:** $VENDOR
**IP:** $IP
**MAC:** $MAC
**Åpne porter:** $PORTS"
        
        echo -e "${RED} [!] Ukjent enhet: $IP ($VENDOR). Porter: $PORTS${NC}" | tee -a "$LOGFILE"
        send_webhook "$ALERT_MSG"
        FOUND_UNKNOWN=true
    fi
done < current_scan.tmp

[ "$FOUND_UNKNOWN" = false ] && echo -e "${GREEN} [OK] Ingen ukjente enheter funnet.${NC}"
rm -f current_scan.tmp