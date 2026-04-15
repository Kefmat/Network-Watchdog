# Network Watchdog (Linux/Bash)

## Hva er dette?
Network Watchdog er et avansert sikkerhetsverktøy bygget i Bash for Ubuntu/Linux. Det fungerer som et automatisert kontrollpunkt som overvåker det lokale nettverket (LAN) for uautoriserte enheter. Ved å kombinere Layer 2-skanning med port-analyse, identifiserer verktøyet aktive noder, validerer deres MAC-adresser mot en kontrollert hvitliste, og analyserer potensielle angrepsflater.

## Hvorfor er dette prosjektet relevant?
Dette prosjektet demonstrerer evnen til å sikre komplekse nettverksmiljøer med strenge krav til integritet og oversikt. Det adresserer kritiske behov innen moderne IT-infrastruktur og sikkerhetsdrift gjennom automatisering og dypere innsikt.

### Asset Management & Intrusion Detection
I miljøer med høye sikkerhetskrav er kontroll på maskinvare ("Asset Management") fundamentalt. Dette verktøyet automatiserer deteksjonen av uautorisert utstyr og utfører umiddelbar analyse av åpne tjenester på ukjente enheter, noe som er et kritisk steg i *Incident Response*.

### Hybrid Kompetanse & Moderne Drift
Ved å inkludere støtte for både lokal kjøring via `setup.sh` og containerisering via **Docker**, demonstreres en dyp forståelse for moderne distribusjonsmetoder og DevOps-prinsipper. Prosjektet viser sømløs operasjon mellom Windows-administrasjon (via WSL) og Linux-drift.

### Automasjon og Robusthet
Verktøyet er klargjort for automatisering via `cron`-jobber, inkluderer sikker håndtering av sensitiv informasjon via konfigurasjonsfiler, og benytter modularisert kode for enkel vedlikeholdbarhet.

## Tekniske Funksjoner
* **Nettverksanalyse:** Bruker `arp-scan` for pålitelig MAC-deteksjon og `nmap` for automatisk port-skanning av ukjente enheter.
* **Smart Varsling:** Integrert med Discord/Slack via Webhooks som sender detaljerte sikkerhetsvarsler inkludert produsentnavn og åpne porter.
* **CLI Administrasjon:** Egne kommandolinje-argumenter (`--add`, `--show`) for effektiv håndtering av hvitlisten.
* **Audit Trail:** Fullstendig loggføring av sikkerhetshendelser med tidsstempler i `logs/watchdog.log`.
* **Automatisert Deployment:** Inkluderer et robust installasjonsskript som håndterer avhengigheter og miljøkonfigurasjon.

## Installasjon

1. **Kjør installasjonsskriptet:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Konfigurer Webhook:**
   Legg til din URL i `config.conf`:
   ```bash
   WEBHOOK_URL="https://discord.com/api/webhooks/..."
   ```

## Bruk

- **Kjør manuelt:**
  ```bash
  ./watchdog.sh
  ```

- **Legg til enhet:**
  ```bash
  ./watchdog.sh --add AA:BB:CC:DD:EE:FF
  ```

- **Vis hjelp:**
  ```bash
  ./watchdog.sh --help
  ```
## Demo
<img width="1024" height="497" alt="image" src="https://github.com/user-attachments/assets/7c3f1423-2391-4d96-ac77-69efb5425157" />


## Docker

Prosjektet er klargjort for kjøring i isolerte miljøer:

```bash
docker build -t network-watchdog .
docker run --network host network-watchdog
```
