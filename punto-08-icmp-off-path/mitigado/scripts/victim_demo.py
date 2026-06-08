#!/usr/bin/env python3
"""Mantiene conexión TCP y muestra MTU de ruta antes/después del ICMP forjado."""
import socket
import subprocess
import sys
import time


def show_route(dst: str, label: str) -> str:
    r = subprocess.run(["ip", "route", "get", dst], capture_output=True, text=True)
    line = r.stdout.strip()
    print(f"[*] {label}: {line}")
    return line


def main() -> None:
    server = sys.argv[1] if len(sys.argv) > 1 else "10.9.0.30"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
    hold = float(sys.argv[3]) if len(sys.argv) > 3 else 10.0
    sport = int(sys.argv[4]) if len(sys.argv) > 4 else 45678

    before = show_route(server, "MTU ANTES")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("", sport))
    s.settimeout(8)
    s.connect((server, port))
    s.send(b"GET / HTTP/1.0\r\nHost: lab\r\n\r\n")
    print(f"[+] TCP activo {sport} -> {server}:{port}")
    time.sleep(hold)
    after = show_route(server, "MTU DESPUÉS")
    s.close()
    if "576" in after and "576" not in before:
        print("[!] MTU reducido en caché de ruta (vulnerable)")
    elif "576" in after:
        print("[!] MTU 576 presente en ruta")
    else:
        print("[+] Ruta sin degradación MTU persistente (mitigado)")


if __name__ == "__main__":
    main()
