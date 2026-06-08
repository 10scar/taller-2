#!/bin/sh
iptables -t mangle -A PREROUTING -f -j DROP 2>/dev/null || true
echo "[+] Mitigación activa: fragmentos IP descartados (iptables -t mangle -f DROP)"
exec tail -f /dev/null
