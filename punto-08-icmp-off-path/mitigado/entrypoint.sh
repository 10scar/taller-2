#!/bin/sh
ROLE="${LAB_ROLE:-}"
if [ "$ROLE" = "victima" ] || ip -4 addr show | grep -q 'inet 10.9.0.20/'; then
  sysctl -w net.ipv4.conf.all.accept_redirects=0 >/dev/null 2>&1 || true
  sysctl -w net.ipv4.conf.default.accept_redirects=0 >/dev/null 2>&1 || true
  sysctl -w net.ipv4.conf.eth0.accept_redirects=0 >/dev/null 2>&1 || true
  sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null 2>&1 || true
  echo "[+] Mitigación: accept_redirects=0, tcp_mtu_probing=1"
fi
exec tail -f /dev/null
