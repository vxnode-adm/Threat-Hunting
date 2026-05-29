# Suspicious IP Detection and Response Tool

This Bash script is a lightweight network security utility designed to identify suspicious IP addresses currently connected to a Linux system. 
It reads a list of potentially malicious IPs from a custom file (`ip_list.txt`) maintained and updated daily by the developer, allowing continuous monitoring against newly identified threats.

## Features

* Reads suspicious IP addresses from a personally maintained and daily updated list
* Scans active TCP/UDP connections for matches using the `ss` command
* Displays detected suspicious IPs
* Allows the user to:

  * Kill associated processes
  * Block IPs using iptables firewall rules
  * Retrieve additional IP information via the ipinfo.io API
* Interactive command-line prompts for safer execution

## How It Works

1. The script reads IP addresses from `ip_list.txt`.
2. It searches current network connections for matching IPs.
3. If suspicious IPs are found, the user can:

   * Terminate related processes
   * Block the IPs at the firewall level
   * Query external geolocation and network information
4. If no matches are found, the script exits safely.

## IP Intelligence List

The `ip_list.txt` file is manually curated and updated daily to include newly discovered suspicious or unwanted IP addresses.
This allows the tool to remain adaptable and continuously improve its detection capabilities over time.

## Use Cases

* Basic incident response
* Monitoring suspicious outbound/inbound connections
* Blocking known malicious IPs
* Educational cybersecurity demonstrations
* Lightweight server/network administration

## Requirements

* Linux-based operating system
* Bash shell
* `ss` command available
* `iptables` installed
* Internet connection for IP information lookup

## Notes

This script should be executed with elevated privileges (`sudo`) for process termination and firewall modifications to work properly.
