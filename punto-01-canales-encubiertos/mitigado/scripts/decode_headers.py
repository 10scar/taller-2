#!/usr/bin/env python3
"""Simula normalización: rechaza IP ID con patrón ASCII encubierto."""
import sys
from scapy.all import sniff, IP, ICMP

def decode(timeout=8):
    blocked = 0
    chars = {}
    def handler(pkt):
        nonlocal blocked
        if pkt.haslayer(IP) and pkt.haslayer(ICMP) and pkt[ICMP].type == 8:
            ip_id = pkt[IP].id
            ch = (ip_id >> 8) & 0xFF
            if 32 <= ch <= 126 and ip_id > 256:
                blocked += 1
                print(f"[!] MITIGADO: IP ID={ip_id} reescrito/normalizado (patrón encubierto)")
                return
            idx = ip_id & 0xFF
            if 32 <= ch <= 126:
                chars[idx] = chr(ch)
    sniff(filter="icmp", prn=handler, timeout=timeout, store=0)
    print(f"[+] Paquetes con canal encubierto neutralizados: {blocked}")
    if chars:
        print(f"[-] Fuga residual: {''.join(chars[i] for i in sorted(chars))}")
    else:
        print("[+] Canal encubierto destruido — sin datos recuperables")
    return 0 if blocked > 0 else 1

if __name__ == "__main__":
    sys.exit(decode())
