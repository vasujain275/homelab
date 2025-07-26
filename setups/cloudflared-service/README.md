# 🛠️ Full Guide: Caddy Reverse Proxy + Cloudflare Tunnel (CLI-Managed)

This guide sets up **Caddy** as the reverse proxy for all your self-hosted services, with **Cloudflare Tunnel** forwarding HTTPS traffic to Caddy on port 2015. This setup is robust, version-controllable, and uses a single `cloudflared` tunnel.

---

## ✅ Prerequisites

- Domain with Cloudflare (e.g., `vasujain.me`)
- Raspberry Pi or Linux server with:
  - `cloudflared` installed
  - `caddy` installed (bare metal preferred)
- Services already running locally (e.g., Immich, Linkding, Gitea, etc.)

---

## 📁 Step 1: Create Cloudflared Tunnel and Config

If not already done:

```bash
cloudflared tunnel create pi-homelab
```

Save the generated credentials JSON (usually at `~/.cloudflared/<uuid>.json`)

Now create the config file:

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

  - hostname: files.vasujain.me
    service: http://localhost:2015

  - service: http_status:404
```

> Replace `xxxxxxxx-xxxx...` with actual UUID filename.

This will forward all public domains to your Caddy running on `localhost:2015`.

---

## 🧩 Step 2: Set Up systemd Service for cloudflared

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

Enable and start it:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

Check status:

```bash
sudo journalctl -u cloudflared -f
```

---

## 🌐 Step 3: Caddy Configuration (Bare Metal)

Edit or create your `Caddyfile` (default: `/etc/caddy/Caddyfile`):

```bash
sudo nano /etc/caddy/Caddyfile
```

Example:

```caddyfile
immich.vasujain.me {
  reverse_proxy localhost:2283
}

linkding.vasujain.me {
  reverse_proxy localhost:9090
}

git.vasujain.me {
  reverse_proxy localhost:9220
}

files.vasujain.me {
  reverse_proxy localhost:9600
}
```

Then restart Caddy:

```bash
sudo systemctl restart caddy
```

---

## 🔒 Optional: Add Local TLS

Since cloudflared handles HTTPS and Caddy is only local:

- You can disable HTTPS enforcement in Caddy using:

```caddyfile
http:// {
  # fallback for local requests
}
```

Or leave as-is since `localhost` traffic doesn’t require TLS.

---

## 🧪 Verify Setup

- Visit `https://immich.vasujain.me`, `https://linkding.vasujain.me`, etc.
- All requests go through:
  1. Cloudflare Edge
  2. cloudflared tunnel
  3. Caddy reverse proxy
  4. Local service

---

## 📂 File Summary

| File                             | Purpose                          |
|----------------------------------|----------------------------------|
| `/etc/cloudflared/config.yaml`  | Tunnel ingress → Caddy          |
| `/etc/systemd/system/cloudflared.service` | Run tunnel as service      |
| `/etc/caddy/Caddyfile`          | Route domains to services        |

---

## 📌 Tips

- Use `journalctl -u caddy -f` and `journalctl -u cloudflared -f` to debug.
- You can use `tailscale` for internal access bypassing Caddy.

---

## ✅ You’re Done!

You now have a **declarative, CLI-managed Cloudflare Tunnel**, with **Caddy** handling all routing to local services like Immich, Linkding, Gitea, etc.

```
