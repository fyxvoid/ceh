#!/bin/bash

# Watcher - Automated Network Scanner
# Usage: ./watcher.sh <interface> <range>
# Example: ./watcher.sh eth0 24

INTERFACE=$1
RANGE=$2

if [ -z "$INTERFACE" ] || [ -z "$RANGE" ]; then
    echo "Usage: $0 <interface> <range>"
    echo "Example: $0 eth0 24"
    exit 1
fi

OUTPUT_DIR="./results"
mkdir -p $OUTPUT_DIR

# Auto detect IP and build subnet
IP=$(ip -o -f inet addr show $INTERFACE | awk '{print $4}' | cut -d'/' -f1 | head -n1)

if [ -z "$IP" ]; then
    echo "[-] Could not detect IP on $INTERFACE"
    exit 1
fi

SUBNET=$(echo $IP | cut -d'.' -f1-3).0/$RANGE

echo "==============================="
echo "  WATCHER - Network Scanner"
echo "==============================="
echo "[*] Interface : $INTERFACE"
echo "[*] IP        : $IP"
echo "[*] Subnet    : $SUBNET"
echo ""

# ==============================
# STEP 1 - HOST DISCOVERY
# ==============================
echo "[*] Step 1: Discovering hosts..."
bash discover.sh $INTERFACE

if [ ! -s $OUTPUT_DIR/hosts.txt ]; then
    echo "[-] No hosts found. Exiting."
    exit 0
fi

echo ""

# ==============================
# STEP 2 - PORT SCANNING
# ==============================
echo "[*] Step 2: Scanning open ports..."

while read IP; do
    bash portscan.sh $IP
    echo ""
done < $OUTPUT_DIR/hosts.txt

# ==============================
# STEP 3 - SERVICE DETECTION
# ==============================
echo "[*] Step 3: Detecting services and OS..."

while read IP; do
    bash services.sh $IP
    echo ""
done < $OUTPUT_DIR/hosts.txt

# ==============================
# SUMMARY
# ==============================
echo "==============================="
echo "[+] Scan Complete"
echo "[+] Results saved in: $OUTPUT_DIR/"
echo ""
echo "[+] Hosts found:"
cat $OUTPUT_DIR/hosts.txt
echo ""
echo "[+] Reports:"
ls $OUTPUT_DIR/nmap_*.txt 2>/dev/null | while read f; do
    echo "    $f"
done
echo "==============================="
