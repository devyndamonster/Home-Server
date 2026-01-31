# Logging Infrastructure

This directory contains the centralized logging setup using Loki + Grafana stack.

## Components

- **Loki** - Log aggregation and storage (port 3100)
- **Promtail** - Log collector that scrapes Docker container logs
- **Grafana** - Web UI for viewing and querying logs (port 3000)

## Quick Start

1. Start the logging stack:
   ```bash
   cd logging
   docker-compose up -d
   ```

2. Access Grafana at http://localhost:3000
   - Default credentials: `admin` / `admin`
   - Change password on first login

3. View logs in Grafana:
   - Go to "Explore" in the left menu
   - Use LogQL queries to filter logs:
     - `{container="firefly_iii_core"}` - View Firefly III logs
     - `{container="mealie"}` - View Mealie logs
     - `{container="pihole"}` - View Pi-hole logs
     - `{compose_service="nginx_proxy"}` - View by service name
     - `{container=~"firefly.*"}` - View all Firefly containers
     - `{container="nginx_proxy"} |= "error"` - Filter for errors

## Log Retention

Logs are retained for 7 days (168 hours). You can adjust this in `loki/loki-config.yml` by changing the `retention_period` value.

## Troubleshooting

- Check if all containers are running: `docker-compose ps`
- View Promtail logs: `docker logs promtail`
- View Loki logs: `docker logs loki`
- Ensure Docker socket is accessible to Promtail

## Useful LogQL Queries

```
# Show all logs from the last hour
{container!=""}

# Show errors from all containers
{container!=""} |= "error"

# Show logs from specific service
{compose_service="firefly_iii_core"}

# Show logs with specific text
{container="nginx_proxy"} |~ "404|500"

# Count errors by container
sum by (container) (count_over_time({container!=""} |= "error" [5m]))
```
