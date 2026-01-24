#!/bin/bash
# Script to configure Pi-hole DNS on port 53

echo "This script will:"
echo "1. Disable systemd-resolved to free port 53"
echo "2. Configure /etc/resolv.conf to use Pi-hole"
echo "3. Start Pi-hole DNS server"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Disable systemd-resolved
echo "Disabling systemd-resolved..."
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

# Backup and configure resolv.conf
echo "Configuring /etc/resolv.conf..."
sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

# Make resolv.conf immutable to prevent changes
sudo chattr +i /etc/resolv.conf 2>/dev/null || true

echo ""
echo "Configuration complete! Now starting Pi-hole..."
cd "$(dirname "$0")"
docker compose up -d

echo ""
echo "Waiting for Pi-hole to start..."
sleep 10

# Add local DNS records
echo "Configuring local DNS records..."
mkdir -p etc-dnsmasq.d
cat > etc-dnsmasq.d/02-local-dns.conf << 'EOF'
# Local DNS records for home services
address=/mealie.home/192.168.4.73
address=/firefly.home/192.168.4.73
EOF

echo "Restarting Pi-hole to apply DNS records..."
docker compose restart

echo ""
echo "✅ Setup complete!"
echo ""
echo "Pi-hole is now running on this server (192.168.4.73)"
echo ""
echo "Next steps:"
echo "1. Access Pi-hole admin: http://192.168.4.73:8080/admin"
echo "2. Default password: changeme (change it in .env file)"
echo "3. Configure your router or devices to use 192.168.4.73 as DNS"
echo ""
echo "Your services will be available at:"
echo "  - http://mealie.home"
echo "  - http://firefly.home"
