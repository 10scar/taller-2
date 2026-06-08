#!/bin/sh
if ip -4 addr show | grep -q 'inet 10.9.0.20/'; then
  ping -c 1 -W 2 10.9.0.1 >/dev/null 2>&1 || true
  sleep 1
  GW_MAC=$(ip neigh show 10.9.0.1 2>/dev/null | awk '{print $5; exit}')
  if [ -n "$GW_MAC" ] && [ "$GW_MAC" != "FAILED" ]; then
    arp -s 10.9.0.1 "$GW_MAC"
    echo "[+] Mitigación: entrada ARP estática gateway 10.9.0.1 -> $GW_MAC"
  fi
fi
exec tail -f /dev/null
