#!/usr/bin/env python3
"""Codifica mensaje en campo IP ID."""
import sys
from scapy.all import IP, ICMP, send

def main():
    dst, msg = sys.argv[1], sys.argv[2]
    print(f"[+] Codificando '{msg}' en IP ID hacia {dst}")
    for i, ch in enumerate(msg):
        ip_id = (ord(ch) << 8) | (i & 0xFF)
        pkt = IP(dst=dst, id=ip_id, flags="DF") / ICMP(type=8, code=0) / f"covert-{i}"
        send(pkt, verbose=False)
        print(f"    paquete {i}: IP ID={ip_id} char={ch!r}")
    print("[+] Transmisión encubierta completada")

if __name__ == "__main__":
    main()
