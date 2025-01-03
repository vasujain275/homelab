# Raspberry Pi Setup Guide

This guide outlines the steps for setting up a Raspberry Pi with Docker, SSH, Tailscale, Syncthing, and other essential tools for a homelab setup.

---

## Table of Contents

1. [OS Installation](#os-installation)
2. [SSH Setup](#setup-ssh-keys)
3. [First System Update](#first-update)
4. [Docker Installation](#docker-install)
5. [Mounting External Drive Persistently](#mounting-external-drive-persistently)
6. [Static IP Configuration](#static-ip-config)
7. [ZSH4HUMANS Setup](#zsh4humans-setup)
8. [Setting Up GitHub SSH Keys](#setting-up-new-github-ssh-keys)
9. [Tailscale Setup](#tailscale-setup)
10. [Cloudflare Tunnels Setup](#cloudflare-tunnels)
11. [Syncthing Setup](#syncthing-setup)

---

## 1. OS Installation

1. **Burn OS to SD Card**:
   - Use **Raspberry Pi Imager** to burn **Raspberry Pi OS Lite 64-bit** to your SD card.
   - Default username: `pi`.

---

## 2. Setup SSH Keys

1. **Copy SSH Key**:
   - On your PC, go to the `~/.ssh` folder and copy the public SSH key you wish to use.

2. **SSH to Raspberry Pi**:
   - SSH into the Raspberry Pi using the password:
     ```bash
     ssh pi@<raspberry-pi-ip>
     ```
   - Run the following commands to set up SSH key authentication:
     ```bash
     mkdir .ssh
     cd .ssh
     touch authorized_keys
     nano authorized_keys
     ```
   - Paste your public key into `authorized_keys` and save.

---

## 3. First System Update

To ensure your Raspberry Pi is up-to-date, run the following commands:
```bash
sudo apt update && sudo apt upgrade
```

---

## 4. Docker Installation

### Uninstall Conflicting Versions

To remove any existing Docker installations:
```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

### Install Docker

1. **Set up Docker's Apt Repository**:
   ```bash
   sudo apt-get update
   sudo apt-get install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc

   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
   ```

2. **Install Docker**:
   ```bash
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

3. **Add User to Docker Group**:
   ```bash
   sudo groupadd docker
   sudo usermod -aG docker $USER
   ```

Refer to the official Docker installation guide for Debian [here](https://docs.docker.com/engine/install/debian/).

---

## 5. Ensure to follow steps in `setups/services/hdd-mount` to mount external hdd on boot
---

## 6. Static IP Configuration

### 1. Find Network Interface Name
```bash
nmcli con show
```
Copy the `name` of the wifi connection.

### 2. Backup Original Settings
```bash
sudo nmcli con show "Name that you copied" | tee original_network_settings.txt
```

### 3. Set Static IP
```bash
sudo nmcli con mod "Name that you copied" ipv4.method manual ipv4.addr 192.168.1.50/24
sudo nmcli con mod "Name that you copied" ipv4.addr 192.168.1.50/24 ipv4.gateway 192.168.1.1 ipv4.dns 1.1.1.1 ipv4.method manual
```

---

## 7. ZSH4HUMANS Setup

To install **ZSH4HUMANS** for an enhanced Zsh experience:
```bash
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi
```

---

## 8. Setting Up New GitHub SSH Keys

### 1. Generate New SSH Key
```bash
ssh-keygen -t ed25519 -C "vasujain275@gmail.com"
```
Use `homelab_gh` as the key name.

### 2. Add SSH Key to the SSH Agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/homelab_gh
```

### 3. Add SSH Key to GitHub
Follow the [GitHub guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

---

## 9. Tailscale Setup

### 1. Install Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### 2. Login
```bash
sudo tailscale login
```

### 3. Enable Subnets
Enable local network access and configure the Raspberry Pi as an exit node:
```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

Enable subnet routes from the admin console and run the following command:
```bash
sudo tailscale up --advertise-routes=192.168.0.0/24,192.168.1.0/24 --advertise-exit-node
```

### 4. Subnet Optimisation for Ethernet
```bash
NETDEV=$(ip route show 0/0 | cut -f5 -d' ')
sudo ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
```

### 5. Enable on Boot
```bash
printf '#!/bin/sh\n\nethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip route show 0/0 | cut -f5 -d" ")" | sudo tee /etc/networkd-dispatcher/routable.d/50-tailscale
sudo chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale
```

---

## 10. Cloudflare Tunnels Setup

1. Navigate to **Cloudflare Dashboard** > **Zero Trust** > **Networks** > **Tunnels**.
2. Configure the tunnel as per the instructions.

---

## 11. Syncthing Setup

### 1. Install Syncthing
```bash
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo apt-get update
sudo apt-get install syncthing
```

### 2. Enable and Start the Service
```bash
sudo systemctl enable syncthing@pi.service
sudo systemctl start syncthing@pi.service
```

---
