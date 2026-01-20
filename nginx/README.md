# Nginx Reverse Proxy Setup

This nginx configuration provides reverse proxy access to your homeserver services using human-readable URLs.

## Services Configured

- **Mealie**: http://mealie.home
- **Firefly III**: http://firefly.home

## Setup Instructions

### 1. Start the nginx proxy

```bash
cd nginx
docker compose up -d
```

### 2. Restart your services

Since we've added the nginx network, restart your services:

```bash
cd ../firefly
docker compose down && docker compose up -d

cd ../mealie
docker compose down && docker compose up -d
```

### 3. Configure DNS

Add these entries to your local DNS or `/etc/hosts` file:

```
<YOUR_SERVER_IP> mealie.home
<YOUR_SERVER_IP> firefly.home
```

For example, if your server IP is `192.168.1.100`:
```
192.168.1.100 mealie.home
192.168.1.100 firefly.home
```

#### On Linux/Mac
Edit `/etc/hosts` (requires sudo):
```bash
sudo nano /etc/hosts
```

#### On Windows
Edit `C:\Windows\System32\drivers\etc\hosts` (requires admin rights)

### 4. Access Your Services

Open your browser and navigate to:
- http://mealie.home
- http://firefly.home

## Port Information

- **nginx**: Listening on ports 80 (HTTP) and 443 (HTTPS - ready for future SSL)
- **mealie**: Internal on port 9000, external port 9925 still available for direct access
- **firefly**: Internal on port 8080, external port 80 still available for direct access

## Adding HTTPS Later

When you're ready to add HTTPS:

1. Generate self-signed certificates or set up Let's Encrypt
2. Update the nginx configs in `conf.d/` to use SSL
3. Place certificates in `ssl/` directory
4. Restart nginx: `docker compose restart`

## Troubleshooting

**Can't reach services?**
- Check nginx is running: `docker ps | grep nginx`
- Check services are on the nginx network: `docker network inspect nginx_proxy`
- Verify DNS/hosts file entries

**Services not connecting?**
- Ensure all services are running: `docker ps`
- Check nginx logs: `docker logs nginx_proxy`
