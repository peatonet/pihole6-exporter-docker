# 📦 Pi-hole 6 Exporter (HTTP/HTTPS) – Docker Image

A lightweight Docker container image with **Pi-hole 6 Exporter**, based on the [bazmonk/pihole6_exporter](https://github.com/bazmonk/pihole6_exporter) project — now with **multiprotocol support**: HTTP and HTTPS.

> ✅ Supports **ARM (Raspberry Pi)**, **AMD64**, and more  
> 🔐 Connect via **HTTP or HTTPS**  
> 📈 Scrape metrics with **Prometheus** and visualize them in **Grafana**

---

## 🚀 Run via Docker

### ▶️ With HTTP
```
bash
docker run -d \
  -p 9666:9666 \
  -e PIHOLE_HOST=<IP_OR_HOSTNAME> \
  -e PIHOLE_API_KEY=<YOUR_API_KEY> \
  -e PIHOLE_SCHEME=http \
  -e PIHOLE_PORT=80 \
  amonacoos/pihole6_exporter:latest
```

### 🔒 With HTTPS (default for official Pi-hole 6 exporter)
```
bash
docker run -d \
  -p 9666:9666 \
  -e PIHOLE_HOST=<IP_OR_HOSTNAME> \
  -e PIHOLE_API_KEY=<YOUR_API_KEY> \
  -e PIHOLE_SCHEME=https \
  -e PIHOLE_PORT=443 \
  amonacoos/pihole6_exporter:latest
```

---

## 🔑 How to Get Your Pi-hole API Key

> ⚠️ You must use an **App Password**, not the legacy API token. Passing the legacy token will fail auth and the container will exit with `RuntimeError: Pi-hole auth failed: password incorrect`.

1. Open the **Pi-hole Web Interface**
2. Go to **Settings > API / Web interface**
3. Expand **Expert Options**
4. Click **Configure App Password**
5. Copy the API key and **enable it**

---

## 🛠 Docker Compose Example

```
yaml
services:
  pihole6-exporter:
    image: amonacoos/pihole6_exporter:latest
    container_name: pihole6_exporter
    environment:	
      - PIHOLE_HOST=<IP_OR_HOSTNAME>
      - PIHOLE_API_KEY=<YOUR_API_KEY>
      - PIHOLE_SCHEME=http
      - PIHOLE_PORT=80
    restart: unless-stopped
    ports:
      - "9666:9666"
```

---

## 📊 Prometheus Configuration

Add the following job to your Prometheus `scrape_configs`:
```
yaml
- job_name: 'pihole6-exporter'
  scrape_interval: 30s
  static_configs:
    - targets: ['<PIHOLE_HOST>:9666']
```

---

## 📈 Grafana Dashboard

Import the official Pi-hole 6 Stats dashboard:

🔗 [**Pi-hole ver6 stats – Grafana Dashboard #21043**](https://grafana.com/grafana/dashboards/21043-pi-hole-ver6-stats/)

![Pi-hole ver6 stats](https://grafana.com/api/dashboards/21043/images/16250/image)

---

## 🐳 Docker Hub

📦 [**amonacoos/pihole6_exporter** on Docker Hub](https://hub.docker.com/r/amonacoos/pihole6_exporter/)