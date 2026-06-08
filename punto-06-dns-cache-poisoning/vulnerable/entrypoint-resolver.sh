#!/bin/sh
echo "[+] Resolvedor recursivo en 10.9.0.53 -> auth 10.9.0.120"
exec dnsmasq -k -C /etc/dnsmasq/resolver.conf
