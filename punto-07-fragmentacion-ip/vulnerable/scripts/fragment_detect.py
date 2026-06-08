#!/usr/bin/env python3
"""Escucha UDP/9999 y reporta si EVILPAYLOAD fue reensamblado."""
import socket
import sys

PORT = 9999


def main() -> None:
    print(f"[*] Escuchando UDP/{PORT} esperando reensamblaje de fragmentos...")
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.settimeout(25)
    sock.bind(("0.0.0.0", PORT))
    try:
        data, addr = sock.recvfrom(65535)
        print(f"[+] Datagrama reensamblado de {addr[0]}:{addr[1]} ({len(data)} bytes)")
        print(f"    Payload: {data!r}")
        if b"EVILPAYLOAD" in data:
            print("[!] ALERTA: EVILPAYLOAD detectado — evasión por fragmentación exitosa")
            sys.exit(0)
        print("[-] EVILPAYLOAD no presente en payload reensamblado")
        sys.exit(1)
    except socket.timeout:
        print("[-] Timeout: no se recibió datagrama (fragmentos descartados o no llegaron)")
        sys.exit(1)


if __name__ == "__main__":
    main()
