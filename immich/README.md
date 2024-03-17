# Immich for Photo Backups and Sync

## Sync and Backup

Make sure to setup Syncthing folder to back up all your images


## Updating the Server
To update Immich Server, manually run the following command 

**Please Read Release Notes for Any Breaking Changes before Updating the Server**

```zsh
docker compose down
docker compose pull && docker compose up -d
```
