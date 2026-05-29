#! /bin/bash

echo "Reading IPs from the List..."
suspicious_ips=$(ss -tupln | grep -f ip_list.txt | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort | uniq)
if [ -z "$suspicious_ips" ]; then 
    echo "No suspicious IPs found!"
    else 
    echo "Suspicious IPs found: " "$suspicious_ips"
    echo "Do you want to kill the processes associated with these IPs? (y/n)"
    read -r answer

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        kill -9 "$suspicious_ips"
        sleep 3
        echo "Process killed for IPs: " "$suspicious_ips"
    else
        echo "Do you want to block the IPs for your system? (y/n)"
        read -r block_answer
        if [ "$block_answer" = "y" ] || [ "$block_answer" = "Y" ]; then
            IPTABLES -A INPUT -s "$suspicious_ips" -j DROP
            sleep 3
            echo "IPs blocked for the system: " "$suspicious_ips"
        else
            echo "No action taken. IPs not blocked and processes not killed."
        fi
    fi

    echo "Do you want more informations on this IPs? (y/n)"
    read -r info_answer
    if [ "$info_answer" = "y" ] || [ "$info_answer" = "Y" ]; then
        echo "Getting infos..."
        sleep 5
        curl -s "https://ipinfo.io/$suspicious_ips/json"
        
    fi
fi  
