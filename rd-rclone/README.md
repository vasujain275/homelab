Here is the process to mount Real Debrid to /home/pi/rd - 

 - Install rclone
 - Use rclone config
 - Choose `n`
 - Choose `webdav`
 - Choose `other`
 - Enter WebDav URL from real-debrid.com
 - Enter your username and password
 - Save and Exit


Move this file to -> /etc/systemd/system/

Then follow these commands - 
```zsh
mkdir ~/rd
sudo systemctl daemon-reload
sudo systemctl enable rclone-debrid-mount.service
sudo systemctl start rclone-debrid-mount.service
sudo systemctl status rclone-debrid-mount.service
```

Refrence Article - https://help.alldebrid.com/en/faq/rclone-webdav
