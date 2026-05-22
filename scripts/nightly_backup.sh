#!/usr/bin/env bash
# Nightly backup - run at 23:00
set -euo pipefail
BACKUP_DIR=${BACKUP_DIR:-/backup/nightly}
RETAIN_DAYS=${RETAIN_DAYS:-14}
DATE=$(date +%Y%m%d)
LOG=/var/log/nightly_backup.log
exec >> "$LOG" 2>&1

echo "=== Nightly Backup: $DATE ==="
mkdir -p "$BACKUP_DIR/$DATE"

# Backup /etc
tar czf "$BACKUP_DIR/$DATE/etc.tar.gz" /etc 2>/dev/null
echo "  /etc backed up"

# Backup /home
tar czf "$BACKUP_DIR/$DATE/home.tar.gz" /home 2>/dev/null
echo "  /home backed up"

# Backup cron jobs
crontab -l > "$BACKUP_DIR/$DATE/crontab.txt" 2>/dev/null || true
echo "  crontab backed up"

# Backup systemd unit files
cp -r /etc/systemd/system "$BACKUP_DIR/$DATE/systemd_units" 2>/dev/null || true
echo "  systemd units backed up"

# Verify
SIZE=$(du -sh "$BACKUP_DIR/$DATE" | cut -f1)
echo "  Backup size: $SIZE"

# Rotate
find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +"$RETAIN_DAYS" -exec rm -rf {} + 2>/dev/null || true
echo "=== Done: $(date) ==="
