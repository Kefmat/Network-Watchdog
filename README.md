# Network Watchdog (Linux/Bash)

## Hva er dette?
Network Watchdog er et sikkerhetsverktøy bygget i Bash for Ubuntu/Linux. Det fungerer som et automatisert kontrollpunkt som overvåker det lokale nettverket (LAN) for uautoriserte enheter. Ved å bruke Layer 2-skanning, identifiserer verktøyet alle aktive noder og validerer deres MAC-adresser mot en kontrollert hvitliste.

## Hvorfor er dette prosjektet relevant?
Dette prosjektet ble utviklet for å demonstrere evnen til å sikre komplekse nettverksmiljøer, med spesielt fokus på kravene i moderne forsvars- og teknologibedrifter som Kongsberg Gruppen.

### Asset Management & Intrusion Detection
I miljøer med høye sikkerhetskrav er kontroll på maskinvare ("Asset Management") fundamentalt. Dette verktøyet automatiserer deteksjonen av "Shadow IT" eller potensielle inntrengere, noe som er et kritisk første steg i *Incident Response*.

### Hybrid Kompetanse (Windows & Linux)
Ved å utvikle dette i et WSL-miljø (Windows Subsystem for Linux), demonstreres evnen til å brobygge mellom Windows-administrasjon og Linux-drift. Dette er essensielt for roller som krever håndtering av variert infrastruktur.

### Automasjon og Prinsipper om Minste Privilegium
Verktøyet er bygget for å være selvgående via `cron`-jobber, og følger sikkerhetsprinsippet om "Least Privilege" ved kun å kreve utvidede rettigheter (sudo) for selve nettverks-interfacet.

## Tekniske Funksjoner
* **Nettverksanalyse:** Bruker `arp-scan` for å hente rå MAC-data, som er mer pålitelig enn ICMP (Ping) i låste nettverk.
* **Logganalyse og Audit Trail:** Alle avvik loggføres med tidsstempel i `logs/watchdog.log`, noe som muliggjør retrospektiv analyse av sikkerhetshendelser.
* **Modularitet:** Enkel integrasjon med varslingssystemer (f.eks. Webhooks eller e-post).

## Installasjon
Installer avhengigheter:
   ```bash
   sudo apt update && sudo apt install arp-scan -y