Register --test-no FIRE-9001 --weight L --network NO --category security --description "Enhanced firewall security audit"

FIREWALL_FOUND=0
FIREWALL_ACTIVE=0

if command -v ufw >/dev/null 2>&1; then
    FIREWALL_FOUND=1
    UFW_STATUS=$(ufw status 2>/dev/null | head -n 1)

    if echo "$UFW_STATUS" | grep -qi "Status: active"; then
        Report "UFW firewall is active"
        FIREWALL_ACTIVE=1
    else
        ReportWarning "UFW firewall is inactive"
        Report "Recommendation: Review UFW rules and enable it if appropriate"
    fi

    if systemctl is-enabled ufw >/dev/null 2>&1; then
        Report "UFW is enabled at boot"
    else
        ReportWarning "UFW is not enabled at boot"
        Report "Recommendation: Enable UFW at startup if it is the selected firewall"
    fi
fi

if command -v firewall-cmd >/dev/null 2>&1; then
    FIREWALL_FOUND=1

    if firewall-cmd --state >/dev/null 2>&1; then
        Report "firewalld is active"
        FIREWALL_ACTIVE=1
    else
        ReportWarning "firewalld is installed but not active"
        Report "Recommendation: Review firewalld service status"
    fi

    if systemctl is-enabled firewalld >/dev/null 2>&1; then
        Report "firewalld is enabled at boot"
    else
        ReportWarning "firewalld is not enabled at boot"
        Report "Recommendation: Enable firewalld at startup if it is the selected firewall"
    fi
fi

if command -v nft >/dev/null 2>&1; then
    if nft list ruleset 2>/dev/null | grep -q '^[[:space:]]*chain '; then
        Report "nftables contains firewall chains"
        FIREWALL_FOUND=1
    fi
fi

if [ "$FIREWALL_FOUND" -eq 0 ]; then
    ReportWarning "No supported firewall manager was detected"
    Report "Recommendation: Verify firewall protection and install a suitable firewall if required"
elif [ "$FIREWALL_ACTIVE" -eq 0 ]; then
    ReportWarning "No active UFW or firewalld service was detected"
    Report "Recommendation: Verify whether nftables or another firewall is enforcing rules"
fi
