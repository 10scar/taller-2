#!/bin/sh
sysctl -w net.ipv4.tcp_challenge_ack_limit=100 >/dev/null 2>&1 || true
echo "[+] Servidor vulnerable: tcp_challenge_ack_limit=100 (default bajo)"
nc -lk -p 9999 -s 0.0.0.0 >/dev/null 2>&1 &
exec tail -f /dev/null
