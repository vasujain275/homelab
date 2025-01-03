# Mount External HDD with Systemd Service

To mount your external HDD automatically at boot, follow these steps:

1. **Copy the systemd service file:**

   Copy the `hdd-mount.service` file from your repository to `/etc/systemd/system/`:

   ```zsh
   sudo cp hdd-mount.service /etc/systemd/system/
   ```

2. **Copy the mounting script:**

   Copy the `mount-hdd.sh` script from your repository to `/usr/local/bin/`:

   ```zsh
   sudo cp mount-hdd.sh /usr/local/bin/
   ```

   Make sure the script is executable:

   ```zsh
   sudo chmod +x /usr/local/bin/mount-hdd.sh
   ```

3. **Enable and start the service:**

   Run the following commands to enable and start the service:

   ```zsh
   mkdir ~/hdd
   sudo systemctl daemon-reload
   sudo systemctl enable hdd-mount.service
   ```

4. **Ensure HDD mounts before Docker starts:**

   To ensure that your HDD is mounted before Docker services start, modify the Docker service unit file to depend on `hdd-mount.service`:

   - Open the Docker service unit file for editing:

   ```zsh
   sudo systemctl edit docker.service
   ```

   - Add a `Requires` directive to specify the dependency on `hdd-mount.service`. Place it under the `[Unit]` section:
   
   ```ini
   [Unit]
   Requires=mount-hdd.service

   [Service]
   ExecStartPre=/bin/sleep 30
   ```

   **Note:** Make sure to edit the file above the `# Lines below this comment will be discarded` comment.

5. **Reload systemd and reboot:**

   After editing the Docker service, reload systemd and reboot your system:

   ```zsh
   sudo systemctl daemon-reload
   sudo reboot now
   ```

This setup will ensure that the external HDD is mounted before Docker services are started on your system.

--- 

Let me know if you need anything else!
