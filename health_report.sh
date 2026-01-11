#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/health.conf"

DATE=$(date "+%Y-%m-%d %H:%M:%S")
DATE_SHORT=$(date +%F)

HOSTNAME=$(hostname)
IP_ADDR=$(hostname -i)

REPORT_FILE="$REPORT_DIR/report_$DATE_SHORT.txt"


{
echo "      SYSTEM HEALTH REPORT    "
echo "Date       : $DATE"
echo "Hostname   : $HOSTNAME"
echo "IP Address : $IP_ADDR"
echo ""

echo "---- Uptime & CPU Load ----"
uptime
echo ""

echo "---- Memory & Swap Usage ----"
free -h
echo ""

echo "---- Disk Usage ----"
df -h
echo ""

echo "---- Mounted Storage Devices----"
lsblk
echo ""

echo "---- Logged-in Users----"
who
echo ""
} > "$REPORT_FILE"


ALERTS=""

while read -r fs size used avail usep mount; do
    usage=${usep%\%}
    if [ "$usage" -ge "$DISK_THRESHOLD" ]; then
        ALERTS+="⚠ Disk usage high on $mount ($usep)\n"
    fi
done < <(df -h | awk 'NR>1')

MEM_USED=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
if [ "$MEM_USED" -ge "$MEM_THRESHOLD" ]; then
    ALERTS+="⚠ Memory usage high ($MEM_USED%)\n"
fi

if [ -n "$ALERTS" ]; then
    {
    echo "---- ALERTS ----"
    echo -e "$ALERTS"
    } >> "$REPORT_FILE"
fi


mailx -vs "$EMAIL_SUBJECT" $EMAIL_RECIPIENTS < "$REPORT_FILE"
