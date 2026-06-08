#!/bin/sh
sysctl -w net.ipv4.tcp_challenge_ack_limit=2147483647 >/dev/null
echo "[+] Mitigación activa: tcp_challenge_ack_limit=2147483647"
nc -lk -p 9999 -s 0.0.0.0 >/dev/null 2>&1 &
exec tail -f /dev/null
