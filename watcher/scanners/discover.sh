#!/bin/bash

# Host Discovery
# Usage: ./discover.sh <interface>

INTERFACE=$1

if [ -z "$INTERFACE" ]; then
    echo "Usage: $0 <interface>"
    exit 1
fi

OUTPUT_DIR="./results"
mkdir -p $OUTPUT_DIR

SUBNET=$2

if [ -z "$SUBNET" ]; then
    echo "Error: Could not detect subnet on $INTERFACE"
    exit 1
fi

echo "[*] Interface : $INTERFACE"
echo "[*] Subnet    : $SUBNET"
echo "[*] Running netdiscover..."

netdiscover -i $INTERFACE -P -r $SUBNET -c 1 2>/dev/null | \
grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | \
awk '{print $1}' > $OUTPUT_DIR/hosts.txt

if [ ! -s $OUTPUT_DIR/hosts.txt ]; then
    echo "[-] No hosts found"
    exit 0
fi

echo "[+] Hosts discovered:"
cat $OUTPUT_DIR/hosts.txt
echo "[+] Saved to $OUTPUT_DIR/hosts.txt"
