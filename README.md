# Linux Threat Hunter

A lightweight Linux threat hunting script that monitors active network connections and compares them in real time against a remote IP threat feed hosted on GitHub.

No local files or manual updates are required, the threat intelligence list is fetched live every time the script runs.

---

## What it does

The script inspects active TCP/UDP connections using `ss -tupn` and extracts all active IP addresses from running processes. It then compares them against a remotely maintained threat feed.

If a match is found, the script can:

* Display suspicious IPs
* Block IPs using `iptables` 
* Save firewall rules persistently
* Fetch threat intelligence data 

---

## Threat Feed

The IP list is hosted and maintained on GitHub and updated regularly.

It is fetched live at runtime using:

```text id="g7k2lm"
https://raw.githubusercontent.com/vxnode-adm/Threat-Hunting/main/ip_list.txt
```

The script automatically ignores comments and descriptions and extracts only valid IPv4 addresses.

---

## Requirements

* Linux system
* Bash
* `ss`
* `curl`
* `iptables`
* Root privileges (sudo)

---

## Usage

```bash id="p4x9sa"
chmod +x hunter.sh
sudo ./hunter.sh
```

---

## How it works

1. Reads active connections via `ss -tupn`
2. Fetches remote threat feed in real time
3. Extracts and filters IPv4 addresses
4. Compares active IPs with threat intelligence feed
5. Triggers actions if matches are found

---

## Features

* No local IP list required
* Real-time GitHub threat feed integration
* Automatic IP extraction from raw feed
* Interactive blocking system
* Firewall persistence support
* Threat intelligence lookup via API

---

## Notes

* Requires root privileges for firewall changes
* Designed for defensive security and threat hunting
* Lightweight and dependency-free
