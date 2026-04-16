# Network Watchdog (Linux/Bash)

## Oversikt
Network Watchdog er et automatisert sikkerhetsverktøy utviklet i Bash for Linux-miljøer. Verktøyet fungerer som et kontrollpunkt som overvåker det lokale nettverket (LAN) for uautoriserte enheter. Ved å kombinere Layer 2-skanning med port-analyse, identifiserer verktøyet aktive noder, validerer deres MAC-adresser mot en kontrollert hvitliste, og analyserer potensielle angrepsflater.

## Relevans og Bruksområde
Dette prosjektet demonstrerer evnen til å sikre komplekse nettverksmiljøer med strenge krav til integritet og oversikt.

* **Asset Management:** Automatisert deteksjon av maskinvare og kontroll på autorisert utstyr.
* **Intrusion Detection:** Umiddelbar analyse av åpne tjenester på ukjente enheter som et ledd i Incident Response.
* **Moderne Drift:** Støtte for både lokal kjøring og containerisering via Docker (DevOps-prinsipper).
* **Robusthet:** Klargjort for automatisering via cron-jobber med sikker håndtering av konfigurasjonsdata.

## Tekniske Funksjoner
* **Nettverksanalyse:** Bruker `arp-scan` for pålitelig MAC-deteksjon og `nmap` for automatisk port-skanning.
* **Smart Varsling:** Integrert med Discord/Slack via Webhooks for umiddelbar respons ved sikkerhetsbrudd.
* **CLI Administrasjon:** Dedikerte argumenter (`--add`, `--show`) for effektiv håndtering av hvitlisten.
* **Audit Trail:** Fullstendig loggføring av sikkerhetshendelser med tidsstempler i `logs/watchdog.log`.
* **Automatisert Deployment:** Installasjonsskript (`setup.sh`) som håndterer avhengigheter og miljøkonfigurasjon.

## Installasjon og Konfigurasjon

1. Kjør installasjonsskriptet:
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
