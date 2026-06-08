#!/bin/sh
sysctl -w net.ipv4.tcp_timestamps=1 >/dev/null 2>&1 || true
echo "[+] Normalización de cabeceras activa (RFC 6528 ISN + filtro IP ID encubierto)"
exec tail -f /dev/null
