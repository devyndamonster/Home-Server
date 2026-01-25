# GitHub Copilot Instructions for HomeServer

## Services

This home server runs the following Docker containers:

- **firefly_iii_core** - Personal finance manager (Firefly III)
- **firefly_iii_db** - MariaDB database for Firefly III
- **firefly_iii_importer** - Data importer for Firefly III
- **mealie** - Recipe manager
- **pihole** - DNS server with ad-blocking
- **nginx_proxy** - Reverse proxy for web services
- **portainer** - Container management UI

## Testing Changes

After making changes to services or configurations, always run the health check script to verify everything is working:

```bash
./check_services.sh
```

This script verifies that all containers are running and web services are accessible.
