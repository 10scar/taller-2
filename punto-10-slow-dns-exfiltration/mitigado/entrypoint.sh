#!/bin/sh
if ip -4 addr show | grep -q 'inet 10.9.0.53/'; then
  cat > /etc/dnsmasq.d/lab.conf <<'EOF'
no-resolv
log-queries
log-facility=-
server=/attacker.local/10.9.0.101
# Mitigación: rechazar consultas con nombres excesivamente largos (>64 bytes totales)
# Complemento iptables para bloquear payloads DNS anómalos de exfiltración hex
EOF
  iptables -A INPUT -p udp --dport 53 -m length --length 65:65535 -j DROP 2>/dev/null || true
  iptables -A INPUT -p tcp --dport 53 -m length --length 65:65535 -j DROP 2>/dev/null || true
  echo "[+] Resolvedor mitigado: dnsmasq + filtro longitud consulta"
  exec dnsmasq -k --conf-file=/etc/dnsmasq.d/lab.conf
elif ip -4 addr show | grep -q 'inet 10.9.0.101/'; then
  cat > /etc/dnsmasq.d/lab.conf <<'EOF'
no-resolv
log-queries
log-facility=-
address=/.attacker.local/10.9.0.101
EOF
  exec dnsmasq -k --conf-file=/etc/dnsmasq.d/lab.conf
fi
exec tail -f /dev/null
