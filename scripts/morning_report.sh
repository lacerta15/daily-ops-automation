#!/usr/bin/env bash
# Morning operations report - run at 07:00 daily
set -euo pipefail
REPORT_EMAIL=${REPORT_EMAIL:-admin@example.com}
DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

report() {
cat << EOF
===================================
  MORNING OPS REPORT: $HOSTNAME
  $DATE
===================================

-- SYSTEM UPTIME --
$(uptime)

-- DISK USAGE (> 80%) --
$(df -h | awk 'NR==1 || int($5)>80')

-- MEMORY --
$(free -h)

-- TOP 5 PROCESSES (CPU) --
$(ps aux --sort=-%cpu | head -6 | awk '{print $1,$2,$3,$4,$11}')

-- FAILED SERVICES --
$(systemctl list-units --failed --no-legend 2>/dev/null | head -10 || echo "none")

-- LAST 10 AUTH FAILURES --
$(grep "Failed password" /var/log/secure 2>/dev/null | tail -10 || echo "none")

===================================
EOF
}

report | mail -s "Morning Ops Report: $HOSTNAME $(date +%Y-%m-%d)" "$REPORT_EMAIL" 2>/dev/null ||     report
