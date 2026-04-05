#!/bin/bash

# Service & OS Detection using nmap
# Usage: ./services.sh <ip>  OR  ./services.sh --all

OUTPUT_DIR="./results"

if [ -z "$1" ]; then
    echo "Usage: $0 <ip>"
    echo "       $0 --all   (scan all hosts from discover.sh)"
    exit 1
fi

scan_host() {
    IP=$1
    PORTS_FILE=$OUTPUT_DIR/ports_$IP.txt

    if [ ! -f $PORTS_FILE ]; then
        echo "[-] No ports file for $IP. Run portscan.sh first."
        return
    fi

    PORTS=$(cat $PORTS_FILE)

    echo "[*] Running nmap on $IP (ports: $PORTS) ..."

    sudo nmap -sV -O --osscan-limit -T3 -p $PORTS $IP -oN $OUTPUT_DIR/nmap_$IP.txt 2>/dev/null

    echo "[+] Results saved to $OUTPUT_DIR/nmap_$IP.txt"
}

if [ "$1" == "--all" ]; then
    if [ ! -f $OUTPUT_DIR/hosts.txt ]; then
        echo "[-] hosts.txt not found. Run discover.sh first."
        exit 1
    fi
    while read IP; do
        scan_host $IP
        echo ""
    done < $OUTPUT_DIR/hosts.txt
else
    scan_host $1
fi
