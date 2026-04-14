#!/bin/bash

# --- MODUL: SCANNER ---
# Håndterer nmap-skanning og administrasjon av hvitliste.

# Utfører en lynrask port-skanning av ukjente enheter
scan_ports() {
    local ip="$1"
    if command -v nmap &> /dev/null; then
        # Skanner de 20 vanligste portene og returnerer dem som en liste
        nmap -F --top-ports 20 "$ip" | grep "/tcp" | awk '{print $1}' | paste -sd ", " -
    else
        echo "Nmap mangler"
    fi
}

# Validerer og legger til MAC-adresser i hvitlisten
add_to_whitelist() {
    local mac="$1"
    local whitelist_file="whitelist.txt"
    
    if [[ "$mac" =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]]; then
        if ! grep -qi "$mac" "$whitelist_file"; then
            echo "$mac" >> "$whitelist_file"
            echo "Lagt til $mac i hvitlisten."
        else
            echo "Info: $mac finnes allerede i hvitlisten."
        fi
    else
        echo "Feil: Ugyldig MAC-format."
    fi
}