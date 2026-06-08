#!/usr/bin/env python3
"""Emisor de tunelización ICMP (Taller 2 PDF)."""
from scapy.all import IP, ICMP, send
import sys


def transmitir_payload_icmp(target_ip, string_datos):
    cabecera_ip = IP(dst=target_ip)
    cabecera_icmp = ICMP(type=8, code=0)
    packet = cabecera_ip / cabecera_icmp / string_datos.encode("utf-8")
    send(packet, verbose=False)
    print(f"[+] Datos transmitidos con éxito al host {target_ip}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python3 send_icmp.py <IP_Destino> <Mensaje>")
        sys.exit(1)
    transmitir_payload_icmp(sys.argv[1], sys.argv[2])
