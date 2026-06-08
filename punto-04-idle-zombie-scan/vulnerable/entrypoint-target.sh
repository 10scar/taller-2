#!/bin/sh
echo "[+] Objetivo vulnerable: puerto 80 abierto, sin rp_filter"
nc -lk -p 80 -s 0.0.0.0 >/dev/null 2>&1 &
exec tail -f /dev/null
