# Bruker Linux-base
FROM ubuntu:latest

# Installerer nødvendige verktøy
RUN apt-get update && apt-get install -y \
    arp-scan \
    nmap \
    curl \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Oppretter arbeidsmappe
WORKDIR /app

# Kopierer filene dine inn i containeren
COPY . .

# Gjør skriptene kjørbare
RUN chmod +x watchdog.sh setup.sh

# Kjør skriptet når containeren starter
CMD ["./watchdog.sh"]