# Threat-Hunting Script

Simple Linux threat hunting script focused on detecting suspicious outbound/inbound connections by comparing active network connections against a known threat intelligence IP list.

The script can also enrich detections using ThreatFox IOC data and optionally block suspicious IPs using `iptables`.

---

## Features

### Current Features

* Detects active network connections using:

  * `ss`
  * `netstat` (fallback)

* Downloads and checks a remote threat list from GitHub

* Matches active connections against known suspicious IPs

* Removes duplicate results automatically

* Threat intelligence enrichment using ThreatFox API:

  * Malware family
  * Threat type
  * Confidence score
  * IOC description

* Optional interactive blocking using `iptables`

* Automatic firewall rule persistence:

  * Ubuntu / Debian
  * Fedora / RHEL / CentOS

* Dependency validation before execution

* Filtering of local/private IP ranges:

  * `127.0.0.1`
  * `10.0.0.0/8`
  * `172.16.0.0/12`
  * `192.168.0.0/16`

* Duplicate firewall rule prevention

---

## Planned Features

The following features are planned for future versions:

* Process identification (PID, executable, user)
* IPv6 Support
* Detection of remote ports (`IP:PORT`) for better ThreatFox matching
* Local logging system
* JSON log export
* Cache system for threat intelligence feeds
* Multiple threat intelligence sources:

  * ThreatFox
  * AbuseIPDB
  * AlienVault OTX
  * Spamhaus
* Risk scoring system
* Real-time monitoring mode

---

## Requirements

Install required packages:

### Debian / Ubuntu

```bash
sudo apt install curl jq iptables net-tools iproute2
```

### Fedora / RHEL

```bash
sudo dnf install curl jq iptables net-tools iproute
```

---

## ThreatFox API Key Setup

The script uses ThreatFox to enrich detected IPs with malware intelligence.

### Create a free Auth-Key

1. Open the authentication portal:

https://auth.abuse.ch/

2. Create an account

3. Generate an **Auth-Key** for free

4. Export the key in your terminal:

```bash
export AUTH_KEY="YOUR_AUTH_KEY"
```

To verify:

```bash
echo $AUTH_KEY
```

You should see your key.

---

## Usage

Make the script executable:

```bash
chmod +x script.sh
```

Run:

```bash
./script.sh
```

Or with sudo if required:

```bash
sudo ./script.sh
```

---

Safe Local Testing (Without Real Infection)

You do not need to be infected to test the script.

The GitHub threat list already contains safe testing IPs from:

Google DNS
Cloudflare DNS
Quad9 DNS

This allows you to safely test the detection flow without modifying any local files.

Step 1 — Create a Test Connection

Open a terminal and create an active TCP connection using nc:

nc 8.8.8.8 443

or:

nc 1.1.1.1 443

or:

nc 9.9.9.9 443

These IPs are intentionally included in the threat list for local testing purposes.

The connection will stay active so the script can detect it.

Step 2 — Verify the Connection

Before running the script, confirm that the connection exists:

ss -tupn | grep 8.8.8.8

or:

ss -tupn | grep 1.1.1.1

or:

ss -tupn | grep 9.9.9.9

You should see an active TCP connection.

Step 3 — Run the Script

Run:

./script.sh

Expected output:

[!] Suspicious IPs detected:
8.8.8.8

The script should:

Detect the active connection
Match the IP against the GitHub threat list
Ask if you want additional information
Query ThreatFox
Ask if you want to block the IP

ThreatFox will likely return:

No IOC found

This is expected behavior because Google, Cloudflare and Quad9 are legitimate infrastructure providers.

The purpose of this test is to validate:

Active connection detection
Threat list matching
ThreatFox integration
Blocking workflow
Firewall rule persistence

without requiring an actual compromise or malicious traffic.
