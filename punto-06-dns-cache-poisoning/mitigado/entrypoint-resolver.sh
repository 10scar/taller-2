#!/bin/sh
sysctl -w net.ipv4.conf.all.rp_filter=1 >/dev/null
iptables -A INPUT -p udp --sport 53 -m string --algo bm --string "attacker32" -j DROP
iptables -A INPUT -p udp --sport 53 -m string --algo bm --string "1.1.1.1" -j DROP
echo "[+] Mitigación activa: filtro anti-envenenamiento (respuestas spoof/forjadas)"
exec dnsmasq -k -C /etc/dnsmasq/resolver.conf
