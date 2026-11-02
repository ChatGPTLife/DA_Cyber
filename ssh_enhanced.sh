Register --test-no SSH-9001 --weight L --network NO --category security --description "Enhanced SSH security audit"

SSH_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSH_CONFIG" ]; then
    ReportWarning "SSH configuration file not found"
else
    if ! command -v sshd >/dev/null 2>&1; then
        ReportWarning "SSH server utility sshd is unavailable"
    else
        SSH_SETTINGS=$(sshd -T 2>/dev/null)

        if [ -z "$SSH_SETTINGS" ]; then
            ReportWarning "Unable to read effective SSH configuration"
            Report "Recommendation: Validate sshd configuration before auditing"
        else
            get_ssh_setting() {
                printf '%s\n' "$SSH_SETTINGS" |
                    awk -v key="$1" '$1 == key {print $2; exit}'
            }

            ROOT_LOGIN=$(get_ssh_setting permitrootlogin)

            case "$ROOT_LOGIN" in
                no)
                    Report "SSH root login is disabled"
                    ;;
                prohibit-password|without-password)
                    Report "SSH root login is restricted to non-password authentication"
                    ;;
                yes)
                    ReportWarning "SSH root login is permitted"
                    Report "Recommendation: Set PermitRootLogin no"
                    ;;
                *)
                    ReportWarning "Unable to determine effective root login policy"
                    ;;
            esac

            PASSWORD_AUTH=$(get_ssh_setting passwordauthentication)

            if [ "$PASSWORD_AUTH" = "yes" ]; then
                ReportWarning "SSH password authentication is enabled"
                Report "Recommendation: Consider key-based authentication where appropriate"
            elif [ "$PASSWORD_AUTH" = "no" ]; then
                Report "SSH password authentication is disabled"
            else
                ReportWarning "Unable to determine password authentication setting"
            fi

            EMPTY_PASSWORDS=$(get_ssh_setting permitemptypasswords)

            if [ "$EMPTY_PASSWORDS" = "yes" ]; then
                ReportWarning "SSH permits empty passwords"
                Report "Recommendation: Set PermitEmptyPasswords no"
            elif [ "$EMPTY_PASSWORDS" = "no" ]; then
                Report "SSH empty-password authentication is disabled"
            fi

            PUBLIC_KEY=$(get_ssh_setting pubkeyauthentication)

            if [ "$PUBLIC_KEY" = "no" ]; then
                ReportWarning "SSH public-key authentication is disabled"
                Report "Recommendation: Enable public-key authentication if required"
            elif [ "$PUBLIC_KEY" = "yes" ]; then
                Report "SSH public-key authentication is enabled"
            fi

            MAX_TRIES=$(get_ssh_setting maxauthtries)

            if [[ "$MAX_TRIES" =~ ^[0-9]+$ ]]; then
                if [ "$MAX_TRIES" -gt 4 ]; then
                    ReportWarning "SSH MaxAuthTries exceeds 4"
                    Report "Recommendation: Consider setting MaxAuthTries to 4 or lower"
                else
                    Report "SSH authentication attempt limit is 4 or lower"
                fi
            else
                ReportWarning "Unable to determine SSH authentication attempt limit"
            fi
        fi
    fi
fi

if systemctl is-active --quiet ssh 2>/dev/null ||
   systemctl is-active --quiet sshd 2>/dev/null; then
    Report "SSH service is active"
else
    Report "SSH service is not active or could not be detected"
fi
