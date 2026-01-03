#!/bin/bash

# Mealie Backup Script
# Creates a backup via Mealie API and saves it to flash drive

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
MEALIE_URL="http://localhost:9925"
FLASH_DRIVE="/media/devyn-myers/25F4-4EDE"
BACKUP_DIR="$FLASH_DRIVE/mealie-backups"

# Load API key from .env file
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

MEALIE_API_KEY=$(grep "MEALIE_API_KEY=" "$ENV_FILE" | cut -d'=' -f2)

if [ -z "$MEALIE_API_KEY" ]; then
    echo "Error: MEALIE_API_KEY not found in .env file"
    exit 1
fi

# Check if flash drive is mounted
if [ ! -d "$FLASH_DRIVE" ]; then
    echo "Error: Flash drive not found at $FLASH_DRIVE"
    exit 1
fi

# Create backup directory on flash drive if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Creating Mealie backup..."

# Step 1: Create backup via API
CREATE_RESPONSE=$(curl -s -X POST "$MEALIE_URL/api/admin/backups" \
    -H "Authorization: Bearer $MEALIE_API_KEY" \
    -H "Content-Type: application/json")

if [ $? -ne 0 ]; then
    echo "Error: Failed to create backup"
    exit 1
fi

echo "Backup created successfully"

# Step 2: Get list of backups to find the latest one
BACKUPS=$(curl -s -X GET "$MEALIE_URL/api/admin/backups" \
    -H "Authorization: Bearer $MEALIE_API_KEY")

# Extract the most recent backup filename (assuming it's the first in the list)
BACKUP_FILENAME=$(echo "$BACKUPS" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data['imports'][0]['name']) if data.get('imports') else exit(1)")

if [ -z "$BACKUP_FILENAME" ]; then
    echo "Error: Could not find backup filename"
    exit 1
fi

echo "Latest backup: $BACKUP_FILENAME"

# Step 3: Get download token
TOKEN_RESPONSE=$(curl -s -X GET "$MEALIE_URL/api/admin/backups/$BACKUP_FILENAME" \
    -H "Authorization: Bearer $MEALIE_API_KEY")

FILE_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import json, sys; print(json.load(sys.stdin)['fileToken'])")

if [ -z "$FILE_TOKEN" ]; then
    echo "Error: Could not get download token"
    exit 1
fi

# Step 4: Download the backup file
OUTPUT_FILE="$BACKUP_DIR/$BACKUP_FILENAME"

echo "Downloading backup to $OUTPUT_FILE..."

curl -s -X GET "$MEALIE_URL/api/utils/download?token=$FILE_TOKEN" \
    -H "Authorization: Bearer $MEALIE_API_KEY" \
    -o "$OUTPUT_FILE"

if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "✓ Backup saved successfully: $OUTPUT_FILE ($FILE_SIZE)"
    
    # Clean up old backups (keep last 5)
    echo "Cleaning up old backups (keeping last 5)..."
    cd "$BACKUP_DIR"
    ls -t mealie_*.zip 2>/dev/null | tail -n +6 | xargs -r rm -f
    
    echo "Done!"
else
    echo "Error: Failed to download backup"
    exit 1
fi
