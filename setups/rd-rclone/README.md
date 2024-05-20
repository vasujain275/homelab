Here is the process to mount Real Debrid to /home/pi/rd - 

## Rclone Setup - 

 - Install rclone
 - Use rclone config
 - Choose `n`
 - Choose name `rd`
 - Choose `webdav`
 - Choose `other`
 - Enter WebDav URL from real-debrid.com
 - Enter your username and password
 - Save and Exit


## Move `rclone-debrid-mount.service` file to -> /etc/systemd/system/

## Update `/etc/fuse.conf` and uncommnet the following - 

```
user_allow_other
```

## Then follow these commands - 

```zsh
mkdir ~/rd
sudo systemctl daemon-reload
sudo systemctl enable rclone-debrid-mount.service
sudo systemctl start rclone-debrid-mount.service
sudo systemctl status rclone-debrid-mount.service
```

Refrence Article - https://help.alldebrid.com/en/faq/rclone-webdav
