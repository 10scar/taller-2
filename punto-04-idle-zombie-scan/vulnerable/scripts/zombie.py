#!/usr/bin/env python3
"""Host zombie: responde TCP con RST e IP ID incremental."""
from scapy.all import sniff, IP, TCP, send

counter = [1000]


def handle(pkt):
    if not (pkt.haslayer(IP) and pkt.haslayer(TCP)):
        return
    ip_id = counter[0]
    counter[0] += 1
    rst = IP(dst=pkt[IP].src, src=pkt[IP].dst, id=ip_id) / TCP(
        dport=pkt[TCP].sport,
        sport=pkt[TCP].dport,
        flags="RA",
        seq=pkt[TCP].ack if pkt[TCP].flags & 0x10 else 0,
    )
    send(rst, verbose=False)
    print(f"[*] RST IP.ID={ip_id} -> {pkt[IP].src}:{pkt[TCP].sport}")


print("[+] Zombie activo — IP ID incremental en respuestas RST")
sniff(filter="tcp", prn=handle, store=0)
