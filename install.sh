#!/bin/bash
set -e

echo "Installing System Health Reporter"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/health.conf"

echo "Installing dependencies..."
sudo pacman -Sy --noconfirm s-nail cronie inetutils


 
mkdir -p "$BASE_DIR/reports"
chmod +x "$BASE_DIR/health_report.sh"


# Email (SMTP) setup
if [ "$EMAIL_BACKEND" = "gmail" ]; then
    echo "Configuring mailx for Gmail SMTP..."

    cat > "$HOME/.mailrc" <<EOF
set smtp=$SMTP_SERVER
set smtp-auth=login
set smtp-auth-user=$SMTP_USER
set smtp-auth-password=$SMTP_APP_PASSWORD
set from="$SMTP_FROM"
set ssl-verify=ignore
EOF

    chmod 600 "$HOME/.mailrc"
    echo "mailx SMTP configuration written to ~/.mailrc"
else
    echo "Email backend disabled or not configured"
fi

echo "Testing email delivery..."
if ! echo "Health Reporter SMTP test" | mailx -s "SMTP Test" "$EMAIL_RECIPIENTS"; then
    echo "ERROR: Email test failed. Check SMTP credentials."
    exit 1
fi

echo "Enabling cron service..."

sudo systemctl enable --now cronie
CRON_CMD="$BASE_DIR/health_report.sh"
CRON_JOB="$CRON_SCHEDULE $CRON_CMD"

if [ "$CRON_ENABLED" = true ]; then
    echo "Configuring cron job..."

    crontab -l 2>/dev/null | grep -v "$CRON_CMD" | crontab -
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

    echo "Cron scheduled: $CRON_JOB"
else
    echo "Cron disabled via config"
fi

echo ""
echo "Installation complete."
echo "Test manually with:"
echo "  ./health_report.sh"
