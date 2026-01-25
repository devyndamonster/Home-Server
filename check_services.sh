#!/bin/bash

# HomeServer Service Health Check Script
# Tests all services for container status and HTTP connectivity

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track overall status
FAILURES=0

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}HomeServer Health Check${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to check container status
check_container() {
    local container_name=$1
    local service_name=$2
    
    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        local status=$(docker inspect --format='{{.State.Status}}' "$container_name")
        if [ "$status" = "running" ]; then
            # Check if container has health check
            local health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$container_name")
            if [ "$health" = "healthy" ] || [ "$health" = "no-healthcheck" ]; then
                echo -e "  ${GREEN}✓${NC} Container running"
                return 0
            else
                echo -e "  ${YELLOW}⚠${NC} Container running but unhealthy (${health})"
                return 1
            fi
        else
            echo -e "  ${RED}✗${NC} Container exists but not running (${status})"
            return 1
        fi
    else
        echo -e "  ${RED}✗${NC} Container not found"
        return 1
    fi
}

# Function to check HTTP connectivity
check_http() {
    local url=$1
    local expected_code=${2:-200}
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_code" ]; then
        echo -e "  ${GREEN}✓${NC} HTTP ${expected_code} OK"
        return 0
    elif [ "$response" = "000" ]; then
        echo -e "  ${RED}✗${NC} Connection failed"
        return 1
    else
        echo -e "  ${YELLOW}⚠${NC} HTTP ${response} (expected ${expected_code})"
        return 1
    fi
}

# Check Nginx (proxy)
echo -e "${BLUE}[1/5]${NC} Nginx Proxy"
check_container "nginx_proxy" "Nginx" || ((FAILURES++))
echo ""

# Check Firefly III
echo -e "${BLUE}[2/6]${NC} Firefly III (Personal Finance)"
check_container "firefly_iii_core" "Firefly" || ((FAILURES++))
check_container "firefly_iii_db" "Firefly DB" || ((FAILURES++))
check_container "firefly_iii_importer" "Firefly Importer" || ((FAILURES++))
check_http "http://firefly.home" "302" || ((FAILURES++))
check_http "http://localhost:81" "302" || ((FAILURES++))
echo ""

# Check Mealie
echo -e "${BLUE}[3/6]${NC} Mealie (Recipe Manager)"
check_container "mealie" "Mealie" || ((FAILURES++))
check_http "http://mealie.home" "200" || ((FAILURES++))
echo ""

# Check Pi-hole
echo -e "${BLUE}[4/6]${NC} Pi-hole (DNS & Ad Blocking)"
check_container "pihole" "Pi-hole" || ((FAILURES++))
check_http "http://pihole.home/admin" "308" || ((FAILURES++))
echo ""

# Check Portainer
echo -e "${BLUE}[5/6]${NC} Portainer (Container Management)"
check_container "portainer" "Portainer" || ((FAILURES++))
# Portainer usually runs on port 9000 or 9443, check if accessible
if docker port portainer 2>/dev/null | grep -q "9000"; then
    local port=$(docker port portainer | grep "9000" | cut -d: -f2)
    check_http "http://localhost:${port}" "200" || ((FAILURES++))
elif docker port portainer 2>/dev/null | grep -q "9443"; then
    echo -e "  ${BLUE}ℹ${NC} Running on HTTPS (port 9443)"
else
    echo -e "  ${YELLOW}⚠${NC} Port not exposed"
fi
echo ""

# Summary
echo -e "${BLUE}================================${NC}"
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ ${FAILURES} check(s) failed${NC}"
    exit 1
fi
