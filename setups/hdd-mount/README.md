Copy this file `hdd-mount.service` to /etc/systemd/system/


Then Run the following commands - 
```zsh
mkdir ~/hdd
sudo systemctl daemon-reload
sudo systemctl enable mount-hdd.service
```


To ensure that your HDD is mounted before Docker services start, you can make the docker.service unit file depend on your mount-hdd.service.

Here's how you can do it:

- Open the Docker service unit file for editing:

```zsh
sudo systemctl edit docker.service
```

- Add a Requires directive to specify the dependency on your mount-hdd.service. You can add it under the [Unit] section:

```ini
[Unit]
Requires=mount-hdd.service

[Service]
ExecStartPre=/bin/sleep 30
```

**Make sure to edit the file above the `Lines below this comment will be discarded` comment in the file**

- Reload and reboot

```zsh
sudo systemctl daemon-reload
sudo reboot now
```
