#!/bin/bash

# Configuration
SOURCE_DIR="/var/www/"                      # Directory to back up
BACKUP_DIR="/backups/daily"                 # Local backup storage
REMOTE_USER="backupuser"                    # Remote server SSH user
REMOTE_HOST="backup.example.com"            # Remote server address
REMOTE_DIR="/backups/daily"                 # Remote backup directory
RETENTION_DAYS=7                            # Days to keep local backups

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create timestamp
TIMESTAMP=$(date +'%Y%m%d')

# Create compressed archive
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
tar -zcf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$SOURCE_DIR" .

# Remove local backups older than retention period
find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Transfer backup to remote server using rsync over SSH
rsync -avz -e ssh "$BACKUP_DIR/$ARCHIVE_NAME" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

# Log completion
echo "Backup and remote transfer completed at $(date)" >> "$BACKUP_DIR/backup_log.txt"
