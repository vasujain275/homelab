# 🛠️ Guide: Caddy Reverse Proxy (Docker) + Cloudflare Tunnel (CLI)

This guide helps you set up **Caddy via Docker Compose** as a reverse proxy for self-hosted services, while using **Cloudflare Tunnel (CLI-managed)** to expose Caddy to the internet securely.

---

## ✅ Prerequisites

- Domain on Cloudflare (e.g., `vasujain.me`)
- `cloudflared` installed and tunnel created (`cloudflared tunnel create pi-homelab`)
- Docker + Docker Compose installed
- Local services (e.g., Immich, Linkding) already running

---

## 📁 Step 1: Cloudflared Tunnel Config

Create tunnel (if not already):

```bash
cloudflared tunnel create pi-homelab
```

This creates a JSON file: `~/.cloudflared/<UUID>.json`

Create the config:

```bash
sudo mkdir -p /etc/cloudflared
sudo nano /etc/cloudflared/config.yaml
```

Paste:

```yaml
tunnel: pi-homelab
credentials-file: /home/pi/.cloudflared/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.json

ingress:
  - hostname: immich.vasujain.me
    service: http://localhost:2015

  - hostname: linkding.vasujain.me
    service: http://localhost:2015

  - hostname: git.vasujain.me
    service: http://localhost:2015

  - service: http_status:404
```

Replace `xxxxxxxx-xxxx...` with actual file name.

---

## ⚙️ Step 2: Setup `cloudflared` as systemd Service

```bash
sudo nano /etc/systemd/system/cloudflared.service
```

Paste:

```ini
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
User=pi  # change if needed
ExecStart=/usr/local/bin/cloudflared tunnel run pi-homelab
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

---

## 📦 Step 3: Caddy with Docker Compose

### 🔹 Directory structure:

```
/home/pi/caddy/
│
├── Caddyfile
├── docker-compose.yaml
└── data/         # auto-created for certificates
```

### 🔹 `Caddyfile`

```caddyfile
immich.vasujain.me {
  reverse_proxy host.docker.internal:2283
}

linkding.vasujain.me {
  reverse_proxy host.docker.internal:9090
}

git.vasujain.me {
  reverse_proxy host.docker.internal:9220
}
```

If running services inside other containers in the same network, replace `host.docker.internal` with container names.

### 🔹 `docker-compose.yaml`

```yaml
version: "3.8"

services:
  caddy:
    image: caddy:alpine
    container_name: caddy
    restart: always
    ports:
      - "2015:2015"  # used internally by cloudflared
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./data:/data
      - ./config:/config
    networks:
      - caddy_net

networks:
  caddy_net:
    driver: bridge
```

> ⚠️ Port `2015` is arbitrary but must match what's in `cloudflared`'s config (`localhost:2015`).

Start it:

```bash
docker compose up -d
```

---

## 🧪 Step 4: Verify Setup

- Visit `https://immich.vasujain.me`
- You should see your local Immich app
- `cloudflared` forwards the domain to `localhost:2015`, which is handled by Caddy (inside Docker)

---

## 🔄 Optional: Restart Everything

```bash
sudo systemctl restart cloudflared
docker compose -f /home/pi/caddy/docker-compose.yaml restart
```

---

## 🗂️ Summary of Key Files

| File | Purpose |
|------|---------|
| `/etc/cloudflared/config.yaml` | Maps domains to `localhost:2015` |
| `~/caddy/Caddyfile` | Reverse proxy definitions |
| `~/caddy/docker-compose.yaml` | Caddy Docker setup |
| `/etc/systemd/system/cloudflared.service` | Tunnel as service |

---

## ✅ You’re Done!

Your public domains are now securely tunneled via Cloudflare to a Caddy instance running in Docker, which routes traffic to your local services using clean code configuration.

```
