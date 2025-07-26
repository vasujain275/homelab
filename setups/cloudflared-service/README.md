# 🛡️ Cloudflare Tunnel (CLI-based) + Caddy Reverse Proxy Setup (Raspberry Pi)

A full guide to replace GUI-managed tunnels with declarative, version-controlled CLI tunnels + Caddy.

---

## ✅ Prerequisites

- `cloudflared` installed (`which cloudflared`)
- A tunnel already created via:

  ```bash
  cloudflared tunnel create pi-homelab
  ```

- Tunnel credentials file saved (usually at `~/.cloudflared/<UUID>.json`)
- Domain set up with Cloudflare
- Caddy installed (bare metal or Docker)

---

## 🔧 Step 1: Create Cloudflare Tunnel Config

Create a file at:

```bash
sudo nano /etc/cloudflared/config.yaml
```

Example content:

```yaml
tunnel: pi-homelab
credentials-file: /home/pi/.cloudflared/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.json

ingress:
  - hostname: immich.vasujain.me
    service: http://localhost:2283

  - hostname: linkding.vasujain.me
    service: http://localhost:9090

  - hostname: git.vasujain.me
    service: http://localhost:9220

  - hostname: files.vasujain.me
    service: http://localhost:9600

  - service: http_status:404
```

> Or forward all traffic to Caddy on `:2015`:

```yaml
  - hostname: immich.vasujain.me
    service: http://localhost:2015
```

---

## ⚙️ Step 2: Create systemd Service

Create a new service file:

```bash
sudo nano /etc/systemd/system/cloudflared.service
```

Paste the following:

```ini
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
User=pi  # Change to your actual user
ExecStart=/usr/local/bin/cloudflared tunnel run pi-homelab
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

> Replace `/usr/local/bin/cloudflared` with output of `which cloudflared`.

---

## 🚀 Step 3: Enable and Start the Tunnel

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

---

## 🪵 Step 4: Verify Status

```bash
sudo journalctl -u cloudflared -f
```

Look for lines like:

```
Connected to tunnel.cloudflare.com
Registered connection ...
```

---

## 🧭 Optional: Use Caddy for All Routing

Instead of defining all services in `config.yaml`, point them all to `localhost:2015`:

```yaml
ingress:
  - hostname: immich.vasujain.me
    service: http://localhost:2015
  - hostname: linkding.vasujain.me
    service: http://localhost:2015
  - service: http_status:404
```

Then in your Caddyfile:

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

> Restart Caddy after changes.

---

## 🆚 GUI vs CLI Tunnel Comparison

| Feature                 | GUI Dashboard              | CLI YAML + Service         |
|------------------------|----------------------------|----------------------------|
| Setup Simplicity       | ✅ Easier                  | ❌ Manual YAML             |
| Version Control Ready  | ❌ No                      | ✅ Yes                     |
| Editing Hostnames      | ✅ GUI Friendly            | ❌ YAML edit + restart     |
| Reproducibility        | ❌ Not portable            | ✅ Fully portable          |
| Works with Caddy       | ✅ Yes                     | ✅ Yes                     |

---

## ✅ Recommended

If you prefer:
- Git-friendly infra
- Systemd services
- Local tunnel config

→ Use **CLI-managed tunnels + Caddy**.

```
