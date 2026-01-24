# HomeServer
My personal home server stuff

## Accessing Services

Services are accessible via local DNS using human-readable URLs:
- **Mealie:** http://mealie.home
- **Firefly III:** http://firefly.home
- **Pi-hole Admin:** http://192.168.4.73:8080/admin

**DNS Setup:** Configure your device or router to use `192.168.4.73` as the DNS server.

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

### Firefly III

Firefly III is a self-hosted personal finance manager that helps track expenses, budgets, and financial goals.

#### Automated Backups

A backup script (`firefly/backup_to_flash.sh`) automatically backs up Firefly III data weekly on Sundays at 10:00 AM to the mounted flash drive at `/media/devyn-myers/25F4-4EDE/firefly-backups/`.

The script:
- Creates a backup of the database, upload volume, and configuration files
- Saves the backup as a date-stamped .tar.gz file to the flash drive
- Keeps the last 5 backups and removes older ones
- Logs output to `firefly/backup.log`

**Manual backup:**
```bash
./firefly/backup_to_flash.sh
```

Or directly with the backup script:
```bash
sudo bash firefly-iii-backuper.sh backup /media/devyn-myers/25F4-4EDE/firefly-backups/firefly_backup_01_04_2026.tar.gz
```

**View backup logs:**
```bash
cat firefly/backup.log
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

### Pi-hole

Pi-hole provides local DNS resolution with ad-blocking capabilities. Configured to resolve custom `.home` domains to the server IP.

**Start Pi-hole:**
```bash
cd pihole
docker compose up -d
```

**Access admin panel:** http://192.168.4.73:8080/admin (password in `pihole/.env`)

**Add local DNS records:**
1. Go to Local DNS → DNS Records in the admin panel
2. Add domain (e.g., `service.home`) pointing to `192.168.4.73`

**Configure devices:** Set DNS server to `192.168.4.73` on your router or individual devices.

### Nginx

Nginx acts as a reverse proxy, routing HTTP requests from human-readable URLs to the appropriate Docker containers.

**Start nginx:**
```bash
cd nginx
docker compose up -d
```

**Add a new service:**
1. Create a config file in `nginx/conf.d/servicename.conf`:
```nginx
server {
    listen 80;
    server_name servicename.home;

    location / {
        proxy_pass http://container_name:port;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
2. Restart nginx: `docker compose restart`
3. Add DNS record in Pi-hole for `servicename.home` → `192.168.4.73`
