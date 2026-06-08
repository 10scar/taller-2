#!/usr/bin/env python3
"""Side-channel Challenge ACK probe (CVE-2016-5696 lab demo)."""
import sys
import time
from scapy.all import IP, TCP, sr1, conf

conf.verb = 0
PORT = 9999


def classify(resp):
    if resp is None:
        return "TIMEOUT"
    if resp.haslayer(TCP):
        flags = int(resp[TCP].flags)
        if flags & 0x04 and flags & 0x10:
            return "RST-ACK"
        if flags & 0x04:
            return "RST"
        if flags & 0x10:
            return "ACK"
        return f"TCP-{flags}"
    return "OTHER"


def probe(server_ip, client_ip):
    print(f"[*] Side-channel Challenge ACK — servidor={server_ip} cliente={client_ip}")
    print(f"[*] Sesión TCP activa en puerto {PORT}; enviando SYN fuera de ventana...")
    results = []
    for i, seq in enumerate([1000, 50000, 100000, 250000, 500000, 900000]):
        pkt = IP(dst=server_ip) / TCP(
            dport=PORT, sport=40000 + i, flags="S", seq=seq
        )
        resp = sr1(pkt, timeout=0.8)
        rtype = classify(resp)
        results.append(rtype)
        print(f"    seq={seq:>7} -> {rtype}")
        time.sleep(0.08)
    counts = {}
    for r in results:
        counts[r] = counts.get(r, 0) + 1
    print(f"[+] Distribución de respuestas: {counts}")
    diversity = len(counts)
    if diversity >= 2:
        print("[+] CANAL COLATERAL ACTIVO: respuestas diferenciadas (vulnerable)")
    else:
        print("[+] Respuestas uniformes — side-channel mitigado")
    return diversity


if __name__ == "__main__":
    server = sys.argv[1]
    client = sys.argv[2] if len(sys.argv) > 2 else "10.9.0.6"
    probe(server, client)
