Register --test-no FIRE-9001 --weight L --network NO --category security --description "Check firewall status"

if [ -x /usr/sbin/ufw ]; then

    FIREWALL_STATUS=$(/usr/sbin/ufw status 2>/dev/null | head -n 1)

    if echo "$FIREWALL_STATUS" | grep -qi "active"; then
        Report "Firewall is active"
    else
        ReportWarning "Firewall is inactive"
        Report "Recommendation: Enable firewall using 'ufw enable'"
    fi

    if systemctl is-enabled ufw >/dev/null 2>&1; then
        Report "UFW is enabled at boot"
    else
        ReportWarning "UFW is not enabled at boot"
        Report "Recommendation: Enable UFW service at startup"
    fi

else
    ReportWarning "UFW firewall is not installed"
    Report "Recommendation: Install and configure UFW"
fi
