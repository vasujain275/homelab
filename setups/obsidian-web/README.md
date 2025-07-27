# Simple Quartz Site with Caddy Auth

This project uses Docker to run a [Quartz](https://quartz.jzhao.xyz/) digital garden. It is protected by a simple username/password prompt handled by a lightweight **Caddy** reverse proxy.

This setup is designed to be exposed to the internet via a **Cloudflare Tunnel**.

***

## 🚀 Setup

1.  **Prepare Directories:**
    Make sure your Obsidian vault exists at `/home/pi/notes` and the Quartz source code is cloned at `/home/pi/services/quartz`.

2.  **Configure Authentication:**
    First, copy the example Caddy configuration to create your own local one.
    ```bash
    cp Caddyfile.example Caddyfile
    ```
    Next, generate a secure password hash by running the command below, replacing `'your_secret_password'` with your desired password.
    ```bash
    docker run caddy caddy hash-password --plaintext 'your_secret_password'
    ```
    Open the new `Caddyfile` and replace the example hash with the one you just generated. You can also change the username from `admin` to whatever you prefer.

3.  **Launch:**
    With your `Caddyfile` configured, simply run Docker Compose.
    ```bash
    docker-compose up -d
    ```

***

## 🌐 Access

* **Local Access:** `http://<your-pi-ip-address>:9111`
* **Cloudflare Tunnel:** Point your existing tunnel's public hostname to the service `http://localhost:9111`.

When you access the site, you'll be prompted for the username and password you configured.
