# HomeServer
My personal home server stuff

## Setup

### Git

Setting up git required creating an SSH key and adding it to github. Helpful guides below:

https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key

https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account

### Docker

Docker enging was installed using [this guide](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

Docker compose was installed using [this guide](https://docs.docker.com/compose/install/linux/#install-the-plugin-manually)

### Mealie

Mealie was installed using [this guide](https://docs.mealie.io/documentation/getting-started/installation/installation-checklist/)

#### Automated Backups

A backup script (`mealie/backup_to_flash.sh`) automatically backs up Mealie data daily at 10:00 AM to the mounted flash drive at `/media/devyn-myers/25F4-4EDE/mealie-backups/`.

The script:
- Creates a backup via the Mealie API
- Downloads the backup .zip file to the flash drive
- Keeps the last 5 backups and removes older ones
- Logs output to `mealie/backup.log`

**Manual backup:**
```bash
./mealie/backup_to_flash.sh
```

**View backup logs:**
```bash
cat mealie/backup.log
```

**Modify schedule:**
```bash
crontab -e
```

### Portainer

Portainer is a container management tool that provides a web UI for managing Docker containers.

To start Portainer:
```bash
docker compose -f portainer/portainer-compose.yaml up -d
```

Access the web UI at: https://localhost:9443
