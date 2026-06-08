#!/usr/bin/env python3
"""Decodifica mensaje desde campo IP ID."""
import sys
from scapy.all import sniff, IP, ICMP

def decode(timeout=8):
    chars = {}
    def handler(pkt):
        if pkt.haslayer(IP) and pkt.haslayer(ICMP) and pkt[ICMP].type == 8:
            if pkt[IP].src == sys.argv[1] if len(sys.argv) > 1 else True:
                ip_id = pkt[IP].id
                idx = ip_id & 0xFF
                ch = chr((ip_id >> 8) & 0xFF)
                if 32 <= ord(ch) <= 126:
                    chars[idx] = ch
                    print(f"[*] IP ID={ip_id} -> idx={idx} char={ch!r}")
    sniff(filter="icmp", prn=handler, timeout=timeout, store=0)
    if not chars:
        print("[-] No se detectó canal encubierto")
        return 1
    msg = "".join(chars[i] for i in sorted(chars))
    print(f"[+] MENSAJE DECODIFICADO: {msg}")
    return 0

if __name__ == "__main__":
    sys.exit(decode())
