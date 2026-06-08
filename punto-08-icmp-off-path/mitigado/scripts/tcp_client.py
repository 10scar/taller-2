#!/usr/bin/env python3
"""Establece conexión TCP y muestra MTU de ruta antes/después."""
import socket
import subprocess
import sys
import time


def show_route(dst):
    r = subprocess.run(["ip", "route", "get", dst], capture_output=True, text=True)
    line = r.stdout.strip()
    print(f"[*] ip route get {dst}: {line}")
    return line


def connect(server, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(8)
    s.connect((server, port))
    s.send(b"GET / HTTP/1.0\r\nHost: lab\r\n\r\n")
    data = s.recv(512)
    print(f"[+] Respuesta servidor ({len(data)} bytes): {data[:80]!r}")
    return s


def main():
    server = sys.argv[1] if len(sys.argv) > 1 else "10.9.0.30"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
    hold = float(sys.argv[3]) if len(sys.argv) > 3 else 8.0

    print("[*] MTU de ruta ANTES del ataque:")
    before = show_route(server)
    sock = connect(server, port)
    time.sleep(hold)
    print("[*] MTU de ruta DESPUÉS del ataque ICMP:")
    after = show_route(server)
    sock.close()
    if "mtu" in after.lower() and "576" in after:
        print("[!] MTU reducido detectado en caché de ruta (vulnerable)")
    elif before == after or "576" not in after:
        print("[+] Ruta estable / MTU no degradado persistentemente (mitigado)")


if __name__ == "__main__":
    main()
