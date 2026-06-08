#!/usr/bin/env python3
"""Receptor de tunelización ICMP (Taller 2 PDF)."""
from scapy.all import sniff, ICMP, Raw, IP


def decodificar_icmp(packet):
    if packet.haslayer(ICMP) and packet[ICMP].type == 8:
        if packet.haslayer(Raw):
            datos_extraidos = packet[Raw].load.decode("utf-8", errors="ignore")
            print(
                f"[*] Origen: {packet[IP].src} -> Mensaje Extraído: {datos_extraidos}"
            )


print("[+] Iniciando la escucha pasiva de tráfico tunelizado ICMP...")
sniff(filter="icmp", prn=decodificar_icmp, store=0, timeout=10)
