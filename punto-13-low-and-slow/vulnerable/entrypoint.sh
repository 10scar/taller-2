#!/bin/sh
if ip -4 addr show | grep -q 'inet 10.9.0.100/'; then
  echo "[*] Servidor listo (limited_server.py vía demo)"
fi
exec tail -f /dev/null
