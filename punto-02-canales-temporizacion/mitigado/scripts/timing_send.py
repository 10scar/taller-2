#!/usr/bin/env python3
"""Canal encubierto por temporización: modula IPD entre paquetes ICMP."""
import sys
import time
from scapy.all import IP, ICMP, send

SHORT = 0.2  # bit 0
LONG = 0.8   # bit 1


def main():
    if len(sys.argv) < 3:
        print("Uso: python3 timing_send.py <IP_Destino> <Bits>")
        sys.exit(1)
    dst, bits = sys.argv[1], sys.argv[2]
    print(f"[+] Codificando '{bits}' por temporización hacia {dst}")
    sync = IP(dst=dst) / ICMP(type=8, code=0) / "sync"
    send(sync, verbose=False)
    print("    paquete sync enviado")
    for i, bit in enumerate(bits):
        delay = LONG if bit == "1" else SHORT
        time.sleep(delay)
        pkt = IP(dst=dst) / ICMP(type=8, code=0) / f"t{i}-{bit}"
        send(pkt, verbose=False)
        print(f"    bit {i}: {bit} (retardo previo={delay}s)")
    print("[+] Transmisión temporal completada")


if __name__ == "__main__":
    main()
