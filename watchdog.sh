#!/bin/bash

# SYNOPSIS: Network Watchdog v1.0 - Linux Edition.
# DESCRIPTION: Skanner det lokale nettverket og varsler om ukjente MAC-adresser.

# Konfigurasjon
WHITELIST="whitelist.txt"
LOGFILE="logs/watchdog.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Sjekk om arp-scan er installert
if ! command -v arp-scan &> /dev/null; then
    echo "FEIL: arp-scan er ikke installert. Kjør: sudo apt install arp-scan"
    exit 1
fi

echo "[$TIMESTAMP] Starter nettverksskanning..."

# Utfør skanning og filtrer ut MAC-adresser
# (Du vil bli bedt om passord her siden vi bruker sudo)
sudo arp-scan --localnet | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' > current_scan.tmp

# Les hver linje fra skanningen
while read -r line; do
    # Henter ut MAC-adressen og IP
    MAC=$(echo $line | awk '{print $2}')
    IP=$(echo $line | awk '{print $1}')

    # Sjekk om MAC-adressen finnes i hvitlisten (ignore case)
    if ! grep -qi "$MAC" "$WHITELIST"; then
        echo " [!] ADVARSEL: Ukjent enhet funnet! IP: $IP - MAC: $MAC" | tee -a "$LOGFILE"
    else
        echo " [OK] Kjent enhet: $IP ($MAC)"
    fi
done < current_scan.tmp

# Rydd opp
rm current_scan.tmp