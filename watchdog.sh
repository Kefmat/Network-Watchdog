#!/bin/bash

# Importer alle moduler
source "./modules/notifier.sh"
source "./modules/reporter.sh"
source "./modules/scanner.sh"

# Konfigurasjon og sjekk
WHITELIST="whitelist.txt"
[ ! -d "logs" ] && mkdir "logs"
[ ! -f "$WHITELIST" ] && touch "$WHITELIST"

# Håndtering av argumenter (bruker funksjonen fra scanner.sh)
if [[ "$1" == "--add" ]]; then
    add_to_whitelist "$2"
    exit 0
fi

# Start skanning
sudo arp-scan --localnet | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' > current_scan.tmp

TABLE_ROWS=""
UNKNOWN_COUNT=0
KNOWN_COUNT=0

while read -r line; do
    IP=$(echo "$line" | awk '{print $1}')
    MAC=$(echo "$line" | awk '{print $2}')
    VENDOR=$(echo "$line" | cut -f3-)

    if ! grep -qi "$MAC" "$WHITELIST"; then
        ((UNKNOWN_COUNT++))
        # Bruker scan_ports fra scanner.sh
        PORTS=$(scan_ports "$IP")
        [ -z "$PORTS" ] && PORTS="Ingen åpne porter funnet"
        
        STATUS="<span style='color: #dc3545; font-weight: bold;'>UKJENT</span>"
        
        # Bruker send_webhook fra notifier.sh
        send_webhook "Sikkerhetsvarsel: Ukjent enhet detektert: $IP ($MAC). Produsent: $VENDOR. Porter: $PORTS"
    else
        ((KNOWN_COUNT++))
        STATUS="Godkjent"
    fi
    TABLE_ROWS+="<tr><td>$IP</td><td>$MAC</td><td>$VENDOR</td><td>$STATUS</td></tr>"
done < current_scan.tmp

# Generer HTML-rapport (fra reporter.sh)
generate_html "$UNKNOWN_COUNT" "$KNOWN_COUNT" "$TABLE_ROWS"

echo "Nettverksskanning fullført. Rapport er generert i logs/report.html"
rm -f current_scan.tmp