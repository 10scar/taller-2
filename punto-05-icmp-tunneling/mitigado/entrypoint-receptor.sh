#!/bin/sh
iptables -A INPUT -p icmp --icmp-type echo-request -m length --length 85:65535 -j DROP
echo "[+] Mitigación activa: DROP ICMP echo-request length 85:65535"
exec tail -f /dev/null
