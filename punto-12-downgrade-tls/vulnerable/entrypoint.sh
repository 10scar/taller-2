#!/bin/sh
nginx
echo "[*] Servidor HTTPS nginx en :443"
exec tail -f /var/log/nginx/access.log
