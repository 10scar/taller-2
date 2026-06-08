#!/bin/sh
echo "[+] DNS autoritativo ejemplo.com en 10.9.0.120"
exec dnsmasq -k -C /etc/dnsmasq/auth.conf
