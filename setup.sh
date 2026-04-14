#!/bin/bash

# --- DOKUMENTASJON ---
# SYNOPSIS: Setup script for Network Watchdog v1.0.
# DESCRIPTION: Installerer avhengigheter, oppretter mapper og setter rettigheter.

# Farger for tilbakemelding
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Network Watchdog: Installasjon ===${NC}"

# 1. Installer avhengigheter
echo -e "\n[1/4] Sjekker avhengigheter (arp-scan, nmap, curl)..."
deps=(arp-scan nmap curl)
missing_deps=()

for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${BLUE}Installerer manglende verktøy: ${missing_deps[*]}...${NC}"
    sudo apt update && sudo apt install -y "${missing_deps[@]}"
else
    echo -e "${GREEN}OK: Alle nødvendige verktøy er allerede installert.${NC}"
fi

# 2. Opprett mapper
echo -e "\n[2/4] Oppretter mapper..."
mkdir -p logs modules
echo "OK: log- og modul-mapper klargjort."

# 3. Klargjør konfigurasjonsfiler
echo -e "\n[3/4] Klargjør filer..."
if [ ! -f "config.conf" ]; then
    echo 'WEBHOOK_URL="lim_inn_her"' > config.conf
    echo -e "${GREEN}OK: config.conf opprettet.${NC}"
fi

if [ ! -f "whitelist.txt" ]; then
    touch whitelist.txt
    echo "OK: whitelist.txt opprettet."
fi

# 4. Sett rettigheter
echo -e "\n[4/4] Setter kjøretillatelser..."
if [ -f "watchdog.sh" ]; then
    chmod +x watchdog.sh
    [ -d "modules" ] && chmod +x modules/*.sh
    echo -e "${GREEN}OK: Alle skript og moduler er nå kjørbare.${NC}"
else
    echo -e "${RED}FEIL: Fant ikke watchdog.sh!${NC}"
fi

echo -e "\n${BLUE}=== Installasjon fullført! ===${NC}"