#!/usr/bin/env python3
"""Decodifica bits midiendo intervalos entre paquetes ICMP (IPD)."""
import sys
import time
from scapy.all import sniff, ICMP, IP

THRESH = 0.5
EXPECTED = "1010"
timestamps = []


def handler(pkt):
    if pkt.haslayer(ICMP) and pkt[ICMP].type == 8:
        src = pkt[IP].src
        if len(sys.argv) > 1 and src != sys.argv[1]:
            return
        ts = time.time()
        timestamps.append(ts)
        print(f"[*] Echo Request de {src} @ {ts:.3f}")


def decode():
    if len(timestamps) < 2:
        print("[-] Insuficientes paquetes para decodificar")
        return 1
    bits = []
    for i in range(1, len(timestamps)):
        ipd = timestamps[i] - timestamps[i - 1]
        bit = "1" if ipd >= THRESH else "0"
        bits.append(bit)
        print(f"[*] IPD[{i - 1}]={ipd:.3f}s -> bit {bit}")
    seq = "".join(bits)
    print(f"[+] Secuencia decodificada: {seq}")
    if seq == EXPECTED:
        print(f"[+] DECODIFICACIÓN EXITOSA: {EXPECTED}")
        return 0
    print(f"[-] Decodificación incorrecta (esperado {EXPECTED})")
    return 1


def main():
    print("[+] Escuchando canal temporal ICMP...")
    sniff(filter="icmp", prn=handler, timeout=12, store=0)
    return decode()


if __name__ == "__main__":
    sys.exit(main())
