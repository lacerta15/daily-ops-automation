#!/usr/bin/env bash
# Check disk usage and alert if threshold exceeded
set -euo pipefail
THRESHOLD=${THRESHOLD:-85}
ALERT_EMAIL=${ALERT_EMAIL:-admin@example.com}

while read -r line; do
    PCT=$(echo "$line" | awk '{gsub(/%/,"",$5); print $5}')
    MOUNT=$(echo "$line" | awk '{print $6}')
    if [[ "$PCT" -gt "$THRESHOLD" ]]; then
        MSG="ALERT: $MOUNT is at ${PCT}% on $(hostname)"
        echo "$MSG" | mail -s "Disk Alert: $(hostname)" "$ALERT_EMAIL" 2>/dev/null || echo "$MSG"
    fi
done < <(df -h | tail -n +2)
