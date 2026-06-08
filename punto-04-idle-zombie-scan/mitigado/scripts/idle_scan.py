#!/usr/bin/env python3
"""Idle scan: deduce puertos abiertos via delta IP ID del zombie."""
import sys
import time
from scapy.all import IP, TCP, sr1, send, conf

conf.verb = 0


def probe_zombie(zombie_ip, sport=54321):
    pkt = IP(dst=zombie_ip) / TCP(dport=54321, sport=sport, flags="SA", seq=1, ack=1)
    resp = sr1(pkt, timeout=2)
    if resp and resp.haslayer(IP):
        return resp[IP].id
    return None


def main():
    if len(sys.argv) < 4:
        print("Uso: python3 idle_scan.py <Zombie_IP> <Target_IP> <Puerto>")
        sys.exit(1)
    zombie, target, port = sys.argv[1], sys.argv[2], int(sys.argv[3])
    print(f"[*] Idle scan: zombie={zombie} objetivo={target} puerto={port}")

    id1 = probe_zombie(zombie)
    print(f"[*] IP ID inicial del zombie: {id1}")
    if id1 is None:
        print("[-] Sin respuesta del zombie")
        return 1

    spoof = IP(src=zombie, dst=target) / TCP(dport=port, sport=54321, flags="S", seq=1)
    send(spoof, verbose=False)
    print(f"[*] SYN spoofed enviado: {zombie} -> {target}:{port}")
    time.sleep(0.8)

    id2 = probe_zombie(zombie, sport=54322)
    print(f"[*] IP ID final del zombie: {id2}")
    if id2 is None:
        print("[-] Sin segunda respuesta del zombie")
        return 1

    delta = id2 - id1
    print(f"[+] Delta IP ID: {delta}")
    if delta >= 1:
        print(f"[+] Puerto {port}/tcp ABIERTO en {target}")
    else:
        print(f"[-] Puerto {port}/tcp cerrado/filtrado (delta={delta})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
