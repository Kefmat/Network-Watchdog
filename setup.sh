#!/bin/bash

# --- DOKUMENTASJON ---
# SYNOPSIS: Setup script for Network Watchdog.
# DESCRIPTION: Automatiserer installasjon av avhengigheter, oppretter nødvendige mapper/filer
# og setter korrekte filrettigheter.
# BRUK: chmod +x setup.sh && ./setup.sh

# Farger for tilbakemelding
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Network Watchdog: Installasjon ===${NC}"

# 1. Installer avhengigheter
echo -e "\n[1/4] Sjekker avhengigheter..."
if ! command -v arp-scan &> /dev/null; then
    sudo apt update && sudo apt install arp-scan -y
else
    echo -e "${GREEN}OK: arp-scan er allerede installert.${NC}"
fi

# 2. Opprett mapper
echo -e "\n[2/4] Oppretter mapper..."
if [ ! -d "logs" ]; then
    mkdir -p logs
    echo "OK: log-mappe opprettet."
else
    echo "OK: log-mappe eksisterer allerede."
fi

# 3. Klargjør konfigurasjonsfiler
echo -e "\n[3/4] Klargjør filer..."
if [ ! -f "config.conf" ]; then
    if [ -f "config.conf.example" ]; then
        cp config.conf.example config.conf
    else
        echo 'WEBHOOK_URL="lim_inn_her"' > config.conf
    fi
    echo -e "${GREEN}OK: config.conf opprettet (Husk å legge til din Webhook URL).${NC}"
fi

if [ ! -f "whitelist.txt" ]; then
    touch whitelist.txt
    echo "OK: whitelist.txt opprettet."
fi

# 4. Sett rettigheter
echo -e "\n[4/4] Setter kjøretillatelser..."
if [ -f "watchdog.sh" ]; then
    chmod +x watchdog.sh
    echo -e "${GREEN}OK: watchdog.sh er nå kjørbar.${NC}"
else
    echo -e "${RED}FEIL: Fant ikke watchdog.sh!${NC}"
fi

echo -e "\n${BLUE}=== Installasjon fullført! ===${NC}"
echo "Neste steg:"
echo "1. Rediger config.conf med din Discord Webhook URL."
echo "2. Legg til kjente MAC-adresser i whitelist.txt."
echo "3. Kjør skanneren med: ./watchdog.sh"