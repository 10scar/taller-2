#!/bin/sh
if ip -4 addr show | grep -q 'inet 10.9.0.103/'; then
  iptables -A INPUT -s 10.9.0.101 -p udp -m hashlimit \
    --hashlimit-above 800/sec --hashlimit-burst 400 \
    --hashlimit-mode srcip --hashlimit-name ldos -j DROP 2>/dev/null || true
  echo "[+] Mitigación: hashlimit UDP desde 10.9.0.101"
fi
exec tail -f /dev/null
