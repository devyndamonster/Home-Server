#!/bin/bash

# Automated Firefly III backup script
# Backs up Firefly III data to flash drive with date-stamped filename

BACKUP_DIR="/media/devyn-myers/25F4-4EDE/firefly-backups"
BACKUP_FILE="firefly_backup_$(date '+%m_%d_%Y').tar.gz"
SCRIPT_DIR="/home/devyn-myers/HomeServer/firefly"
MAX_BACKUPS=5

echo "=== Firefly III Backup Started: $(date) ==="

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Run the backup
echo "Running backup to: $BACKUP_DIR/$BACKUP_FILE"
sudo bash "$SCRIPT_DIR/firefly-iii-backuper.sh" backup "$BACKUP_DIR/$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup completed successfully"
    
    # Keep only the last MAX_BACKUPS backups
    echo "Cleaning up old backups (keeping last $MAX_BACKUPS)..."
    cd "$BACKUP_DIR"
    ls -t firefly_backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm --
    echo "Cleanup complete"
else
    echo "Backup failed!"
fi

echo "=== Firefly III Backup Finished: $(date) ==="
echo ""
