#! /bin/bash



echo "[*] Checking active connections against GitHub threat list..."
sleep 2

THREAT_LIST="https://raw.githubusercontent.com/vxnode-adm/Threat-Hunting/main/ip_list.txt"


for cmd in curl jq grep sort; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[!] Missing dependency: $cmd"
        exit 1
    fi
done

# verifies the API KEY, if you don't have one, you can get it for free by creating an account on https://threatfox-api.abuse.ch/
if [ -z "$AUTH_KEY" ]; then
    echo "[!] AUTH_KEY environment variable not set."
    echo "[*] Example:"
    echo "export AUTH_KEY='your_key_here'"
    exit 1
fi


echo "[*] Downloading threat list..."
sleep 3
threat_ips=$(curl -s "$THREAT_LIST" | \
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')

if [ -z "$threat_ips" ]; then
    echo "[!] Failed to download threat list."
    exit 1
fi


if command -v ss &>/dev/null; then
    active_ips=$(ss -tupn | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
else
    echo "[*] 'ss' not found, using netstat..."
    active_ips=$(netstat -tupn 2>/dev/null | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
fi

# Remove local ips
active_ips=$(echo "$active_ips" | \
grep -vE '^(127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | \
sort -u)


suspicious_ips=$(grep -Ff <(echo "$threat_ips") <<< "$active_ips" | sort -u)

if [ -z "$suspicious_ips" ]; then
    echo "[OK] No suspicious IPs found in active connections."
    exit 0
fi

echo ""
echo "[!] Suspicious IPs detected:"
echo "$suspicious_ips"

echo ""
echo "Do you want more information about these IPs? (y/n)"
read -r information

if [[ "$information" =~ ^[Yy]$ ]]; then

    for ip in $suspicious_ips; do
        echo ""
        echo "[*] Checking ThreatFox for $ip..."

        result=$(curl -s \
        -H "Auth-Key: $AUTH_KEY" \
        -H "Content-Type: application/json" \
        -X POST \
        https://threatfox-api.abuse.ch/api/v1/ \
        -d "{
          \"query\": \"search_ioc\",
          \"search_term\": \"$ip\"
        }")

        status=$(echo "$result" | jq -r '.query_status // "unknown"')

        if [[ "$status" == "ok" ]]; then

            threat=$(echo "$result" | jq -r '.data[0].threat_type // "unknown"')
            malware=$(echo "$result" | jq -r '.data[0].malware_printable // "unknown"')
            confidence=$(echo "$result" | jq -r '.data[0].confidence_level // "unknown"')
            description=$(echo "$result" | jq -r '.data[0].threat_type_desc // "No description"')

            echo "[!] IOC FOUND"
            echo "IP: $ip"
            echo "Threat Type: $threat"
            echo "Malware: $malware"
            echo "Confidence: $confidence"
            echo "Description: $description"

        else
            echo "[INFO] No ThreatFox IOC found for $ip"
            echo "[INFO] Do your own research."
        fi
    done
fi

echo ""
echo "Do you want to block these IPs? (y/n)"
read -r answer

blocked_any=false

if [[ "$answer" =~ ^[Yy]$ ]]; then

    for ip in $suspicious_ips; do
        echo ""
        echo "[*] Blocking IP: $ip"
        sleep 1

        
        if ! sudo iptables -C INPUT -s "$ip" -j DROP 2>/dev/null; then
            sudo iptables -A INPUT -s "$ip" -j DROP
            echo "[+] INPUT blocked for $ip"
        else
            echo "[=] INPUT rule already exists for $ip"
        fi

        
        if ! sudo iptables -C OUTPUT -d "$ip" -j DROP 2>/dev/null; then
            sudo iptables -A OUTPUT -d "$ip" -j DROP
            echo "[+] OUTPUT blocked for $ip"
        else
            echo "[=] OUTPUT rule already exists for $ip"
        fi

        blocked_any=true
    done

    
    if [[ "$blocked_any" == true ]] && command -v iptables-save &>/dev/null; then

        echo ""
        echo "[*] Saving firewall rules..."
        sleep 2

        # Ubuntu/Debian
        if [ -d /etc/iptables ]; then
            sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
            echo "[+] Rules saved to /etc/iptables/rules.v4"

        # RHEL/Fedora /CentOS
        elif [ -f /etc/sysconfig/iptables ]; then
            sudo iptables-save | sudo tee /etc/sysconfig/iptables > /dev/null
            echo "[+] Rules saved to /etc/sysconfig/iptables"

        else
            sudo iptables-save | sudo tee /etc/iptables.backup > /dev/null
            echo "[!] iptables-persistent not detected."
            echo "[+] Backup saved to /etc/iptables.backup"
        fi
    fi
fi

echo ""
echo "[✓] Done."


