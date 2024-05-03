# OS Installation
- Use Rapsberry pi Imager to burn os to sd card
- Make sure to install `Raspberry Pi OS Lite 64-bit`
- Username - `pi`

# Setup ssh keys
- Go to ~/.shh folder on your pc and copy the public ssh key you want to use
- Ssh to raspberrypi using password, then run the following commands

```zsh
mkdir .ssh
cd .ssh
touch authorized_keys
nano authorized_keys  
```

# First Update
```zsh
sudo apt update && sudo apt upgrade
```

# Docker Install
## Uninstall any conflicting versions
Run the following command to uninstall all conflicting packages:

```zsh
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

## Installing Docker through apt

1. Set up Docker's apt repository.
```zsh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

2. Install the Docker packages.
```zsh
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3. Added User to Docker Group - 
```zsh
sudo groupadd docker
sudo usermod -aG docker $USER
```

Refrence - https://docs.docker.com/engine/install/debian/

# Static IP Config

1. Check for interface name
```zsh
nmcli con show
```
Copy the `name` of wifi type.
2. Backup original Settings
```zsh
sudo nmcli con show "Name that you copied" | tee original_network_settings.txt
```
3. Add the prefered static ip 
```zsh
sudo nmcli con mod "Name that you copied" ipv4.method manual ipv4.addr 192.168.1.50/24

sudo nmcli con mod "Name that you copied" ipv4.addr 192.168.1.50/24 ipv4.gateway 192.168.1.1 ipv4.dns 1.1.1.1 ipv4.method manual

```

Refrence - https://nitratine.net/blog/post/how-to-set-a-static-ip-address-on-a-raspberry-pi-5/

# ZSH4HUMANS Setup

```zsh
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi
```

Refrence - https://github.com/romkatv/zsh4humans

# Setting Up New Github SSH Keys

## Generating a new SSH Key
```shell
ssh-keygen -t ed25519 -C "vasujain275@gmail.com"
```
Use `homelab_gh` for key name.

## Adding your SSH key to the ssh-agent

```shell
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/homelab_gh
```

Refrences - [Ref 1](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) 

## Adding a new SSH key to your GitHub account

Follow this guide - https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account

# Tailscale Setup - 

## Install Tailscale - 

```zsh
curl -fsSL https://tailscale.com/install.sh | sh
```

## Login - 

```zsh
sudo tailscale login
```

## Subnets Setup - 

1. To enable local network access / exit node from raspberry pi - 

```zsh
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

2. Now, Enable subnet routes from the admin console
3. Now run the following command on the pi - 

```zsh
sudo tailscale up --advertise-routes=192.168.0.0/24,192.168.1.0/24 --advertise-exit-node
```

Ref - https://tailscale.com/kb/1019/subnets

# Cloudflare Tunnels

Go to `Cloudflare Dashboard` > `Zero Trust` > `Networks` > `Tunnels` then configure.

# Synchting Setup

## Install Syncthing

```zsh
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
```

# Enable and Start the Service

```zsh
sudo systemctl enable syncthing@pi.service
sudo systemctl start syncthing@pi.service
```

