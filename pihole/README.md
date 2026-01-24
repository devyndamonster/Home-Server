# Pi-hole DNS Server

Local DNS server for home network with custom domain resolution.

## Setup

1. **Change the default password** in `.env` file or `docker-compose.yml`
2. Start Pi-hole:
   ```bash
   docker-compose up -d
   ```

3. Access the web interface:
   - URL: http://192.168.4.73:8080/admin
   - Password: (the one you set in .env)

## Configure Your Devices

Point your devices' DNS to this server's IP: **192.168.4.73**

### Router (Recommended - affects all devices):
1. Log into your router's admin panel
2. Find DHCP/DNS settings
3. Set primary DNS to: 192.168.4.73
4. Set secondary DNS to: 1.1.1.1 (or 8.8.8.8)

### Individual Device Examples:

**Windows:**
- Settings → Network & Internet → Change adapter options
- Right-click connection → Properties → IPv4 → Properties
- Set DNS to 192.168.4.73

**macOS:**
- System Preferences → Network → Advanced → DNS
- Add 192.168.4.73

**Linux:**
- Edit /etc/resolv.conf or use NetworkManager

**iPhone/iPad:**
- Settings → Wi-Fi → (i) button → Configure DNS → Manual
- Add 192.168.4.73

**Android:**
- Settings → Wi-Fi → Long press network → Modify → Advanced → DNS
- Set to 192.168.4.73

## Local DNS Records

The following domains resolve to this server (192.168.4.73):
- mealie.home → 192.168.4.73
- firefly.home → 192.168.4.73

These are configured in `etc-dnsmasq.d/02-local-dns.conf` after first startup.

## Adding More Local Domains

After Pi-hole is running, add domains by creating/editing:
`etc-dnsmasq.d/02-local-dns.conf`

Example:
```
address=/newservice.home/192.168.4.73
```

Then restart Pi-hole:
```bash
docker-compose restart
```
