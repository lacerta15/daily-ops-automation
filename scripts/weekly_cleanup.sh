#!/usr/bin/env bash
# Weekly cleanup - run every Sunday at 02:00
set -euo pipefail
LOG_FILE=/var/log/weekly_cleanup.log
exec >> "$LOG_FILE" 2>&1

echo "=== Weekly Cleanup: $(date) ==="

# Clean old logs
find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null
find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null
echo "Old logs cleaned."

# Clean tmp
find /tmp -mtime +7 -delete 2>/dev/null
find /var/tmp -mtime +30 -delete 2>/dev/null
echo "Temp files cleaned."

# Clean yum/dnf cache
if command -v dnf &>/dev/null; then
    dnf clean all 2>/dev/null
elif command -v yum &>/dev/null; then
    yum clean all 2>/dev/null
fi
echo "Package cache cleaned."

# Report disk after cleanup
df -h
echo "=== Done: $(date) ==="
