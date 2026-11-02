Register --test-no SSH-9001 --weight L --network NO --category security --description "Check SSH security settings"

SSH_CONFIG="/etc/ssh/sshd_config"

if [ -f "$SSH_CONFIG" ]; then

    if grep -qi "^PermitRootLogin yes" "$SSH_CONFIG"; then
        ReportWarning "Root login via SSH is enabled"
        Report "Recommendation: Set PermitRootLogin to no"
    else
        Report "Root login via SSH is disabled"
    fi

    if grep -qi "^PasswordAuthentication yes" "$SSH_CONFIG"; then
        ReportWarning "Password authentication is enabled"
        Report "Recommendation: Disable password authentication and use SSH keys"
    else
        Report "Password authentication is disabled"
    fi

    if grep -q "^Port 22" "$SSH_CONFIG"; then
        ReportWarning "SSH is using default port 22"
        Report "Recommendation: Change SSH port to a custom value"
    else
        Report "SSH is using a custom port"
    fi

    if grep -qi "^Protocol 1" "$SSH_CONFIG"; then
        ReportWarning "Insecure SSH Protocol 1 is enabled"
        Report "Recommendation: Use SSH Protocol 2"
    else
        Report "Secure SSH protocol is in use"
    fi

else
    ReportWarning "SSH configuration file not found"
fi
