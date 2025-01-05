# SMB Shared Folder on PI

## Server Side 

### Installation

```zsh
sudo apt update && sudo apt upgrade
sudo apt install samba samba-common-bin
```

### Create shared folder

```zsh
mkdir ~/pi-shared
```

### Configure SMB

```zsh
sudo vim /etc/samba/smb.conf
```

- At the bottom of this file add this - 

```conf
[pi-shared]
path=/home/pi/pi-shared
writeable=Yes
create mask=0666
directory mark=0666
public=no
```

### Config SMB User and Password

```zsh
sudo smbpasswd -a pi
```

- It will ask for password

```zsh
sudo systemctl restart smbd
```

## Client Side Config (GNOME Specific)

- GO to File Browser > Other Locations > Enter Server Address > smb://192.168.1.50/pi-shared
- Then Enter the Username and Password you configured on the Server

## Windows Client Side Config

- Open Terminal and use this command
```bash
net use s: \\192.168.1.50\pi-shared
```


## Refrenced from - https://youtu.be/8QxJWW0mjAs
