#!/bin/sh
set -e
sysctl -w net.ipv4.ip_forward=1 >/dev/null
tc qdisc del dev eth0 root 2>/dev/null || true
tc qdisc add dev eth0 root netem delay 100ms 50ms
echo "[+] Gateway jammer activo: tc netem delay 100ms 50ms"
exec tail -f /dev/null
