# Network Watchdog (Linux/Bash)

## Hva er dette?
Network Watchdog er et sikkerhetsverktøy bygget i Bash for Ubuntu/Linux. Det fungerer som et automatisert kontrollpunkt som overvåker det lokale nettverket (LAN) for uautoriserte enheter. Ved å bruke Layer 2-skanning, identifiserer verktøyet alle aktive noder og validerer deres MAC-adresser mot en kontrollert hvitliste.

## Hvorfor er dette prosjektet relevant?
Dette prosjektet demonstrerer evnen til å sikre komplekse nettverksmiljøer med strenge krav til integritet og oversikt. Det adresserer kritiske behov innen moderne IT-infrastruktur og sikkerhetsdrift.

### Asset Management & Intrusion Detection
I miljøer med høye sikkerhetskrav er kontroll på maskinvare ("Asset Management") fundamentalt. Dette verktøyet automatiserer deteksjonen av uautorisert utstyr eller potensielle inntrengere, noe som er et kritisk første steg i *Incident Response*.

### Hybrid Kompetanse (Windows & Linux)
Ved å utvikle dette i et WSL-miljø (Windows Subsystem for Linux), demonstreres evnen til å operere sømløst mellom Windows-administrasjon og Linux-drift. Denne kryssplattform-forståelsen er essensiell for moderne systemadministrasjon.

### Automasjon og Prinsipper om Minste Privilegium
Verktøyet er klargjort for automatisering via `cron`-jobber, og følger sikkerhetsprinsippet om "Least Privilege" ved kun å kreve utvidede rettigheter (sudo) for selve nettverks-interfacet.

## Tekniske Funksjoner
* **Nettverksanalyse:** Bruker `arp-scan` for å hente rå MAC-data, som er mer pålitelig enn ICMP (Ping) i strengt konfigurerte nettverk.
* **Logganalyse og Audit Trail:** Alle avvik loggføres med tidsstempel i `logs/watchdog.log`, noe som muliggjør retrospektiv analyse av sikkerhetshendelser.
* **Modularitet:** Arkitekturen tillater enkel utvidelse med varslingssystemer som Webhooks eller e-post.

## Installasjon
1. **Installer avhengigheter:**
   ```bash
   sudo apt update && sudo apt install arp-scan -y