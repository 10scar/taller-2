#!/bin/sh
if ip -4 addr show | grep -q 'inet 10.9.0.100/'; then
  iptables -A INPUT -p tcp --syn --dport 80 \
    -m connlimit --connlimit-above 10 --connlimit-mask 32 -j REJECT 2>/dev/null || true
  iptables -A INPUT -p tcp --dport 80 -s 10.9.0.11 \
    -m connlimit --connlimit-above 2 --connlimit-mask 32 -j REJECT 2>/dev/null || true
  echo "[+] Mitigación: connlimit global (10/IP) + límite estricto atacante 10.9.0.11"
fi
exec tail -f /dev/null
