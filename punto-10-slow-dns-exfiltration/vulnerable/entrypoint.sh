#!/bin/sh
if ip -4 addr show | grep -q 'inet 10.9.0.53/'; then
  cat > /etc/dnsmasq.d/lab.conf <<'EOF'
no-resolv
log-queries
log-facility=-
server=/attacker.local/10.9.0.101
EOF
  echo "[*] Resolvedor iniciando (reenvío attacker.local -> 10.9.0.101)"
  exec dnsmasq -k --conf-file=/etc/dnsmasq.d/lab.conf
elif ip -4 addr show | grep -q 'inet 10.9.0.101/'; then
  cat > /etc/dnsmasq.d/lab.conf <<'EOF'
no-resolv
log-queries
log-facility=-
address=/.attacker.local/10.9.0.101
EOF
  echo "[*] DNS atacante iniciando (registra consultas exfiltradas)"
  exec dnsmasq -k --conf-file=/etc/dnsmasq.d/lab.conf
fi
exec tail -f /dev/null
