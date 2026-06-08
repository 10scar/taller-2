#!/bin/sh
sysctl -w net.ipv4.conf.all.rp_filter=1 >/dev/null
sysctl -w net.ipv4.conf.default.rp_filter=1 >/dev/null
sysctl -w net.ipv4.conf.eth0.rp_filter=1 >/dev/null
echo "[+] Mitigación activa: rp_filter=1 (bloqueo IP spoofing)"
nc -lk -p 80 -s 0.0.0.0 >/dev/null 2>&1 &
exec tail -f /dev/null
