#! /bin/bash

echo "Checking active connections against GitHub threat list..."

THREAT_LIST="https://raw.githubusercontent.com/vxnode-adm/Threat-Hunting/main/ip_list.txt"

suspicious_ips=$(ss -tupn | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | grep -Ff <(
    curl -s "$THREAT_LIST" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'
) | sort -u)

if [ -z "$suspicious_ips" ]; then
    echo "No suspicious IPs found in active processes."
    exit 0
fi

echo "Suspicious IPs detected:"
echo "$suspicious_ips"

echo ""
echo "Do you want to block these IPs? (y/n)"
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    for ip in $suspicious_ips; do
        echo "Blocking the IP:" "$ip" "Wait..."
        sudo iptables -A INPUT -s "$ip" -j DROP
        sudo iptables -A OUTPUT -d "$ip" -j DROP
        sleep 5
        echo "Successfully blocked: $ip"
    done
fi
       if command -v iptables-save &> /dev/null; then

        # Ubuntu/Debian
        if [ -d /etc/iptables ]; then
            sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
            echo "Rules saved to /etc/iptables/rules.v4"

        # RHEL/CentOS/Fedora
        elif [ -f /etc/sysconfig/iptables ]; then
            sudo iptables-save | sudo tee /etc/sysconfig/iptables > /dev/null
            echo "Rules saved to /etc/sysconfig/iptables"
        else
            # Backup genérico caso o administrador queira restaurar manualmente
            sudo iptables-save | sudo tee /etc/iptables.backup > /dev/null
            echo "[!] Warning: iptables-persistent not detected. Rules saved temporarily to /etc/iptables.backup"
        fi
    fi

echo ""
echo "Do you want information about the identified IPs? (y/n)"
read -r info_answer

if [[ "$info_answer" =~ ^[Yy]$ ]]; then
    for ip in $suspicious_ips; do
        echo ""
        echo "Information for $ip:"
        sleep 4
        curl -s "https://ipinfo.io/$ip/json"
        echo ""
    done
fi
