#!/bin/bash

# Port Scanner using masscan
# Usage: ./portscan.sh <ip>  OR  ./portscan.sh --all

OUTPUT_DIR="./results"

if [ -z "$1" ]; then
    echo "Usage: $0 <ip>"
    echo "       $0 --all   (scan all hosts from discover.sh)"
    exit 1
fi

scan_host() {
    IP=$1
    echo "[*] Scanning ports on $IP ..."

    sudo masscan $IP -p1-65535 --rate=1000 -oG $OUTPUT_DIR/masscan_$IP.txt 2>/dev/null

    PORTS=$(grep "Ports:" $OUTPUT_DIR/masscan_$IP.txt 2>/dev/null | \
            grep -oP '\d+/open' | cut -d'/' -f1 | paste -sd,)

    if [ -z "$PORTS" ]; then
        echo "[-] No open ports found on $IP"
        return
    fi

    echo "[+] Open ports on $IP : $PORTS"

    # Save ports to a file for nmap.sh to use
    echo $PORTS > $OUTPUT_DIR/ports_$IP.txt
    echo "[+] Saved to $OUTPUT_DIR/ports_$IP.txt"
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
