#!/usr/bin/env python3
"""Servidor HTTP con pool limitado; retiene peticiones incompletas (Slowloris)."""
import socket
import threading

MAX_WORKERS = 3
_slots = threading.Semaphore(MAX_WORKERS)


def _handle(conn: socket.socket) -> None:
    acquired = _slots.acquire(blocking=False)
    if not acquired:
        conn.close()
        return
    try:
        conn.settimeout(300)
        buf = b""
        while b"\r\n\r\n" not in buf:
            chunk = conn.recv(256)
            if not chunk:
                break
            buf += chunk
        if b"\r\n\r\n" in buf:
            conn.send(b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK")
        else:
            threading.Event().wait(300)
    finally:
        _slots.release()
        try:
            conn.close()
        except OSError:
            pass


def main() -> None:
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("0.0.0.0", 80))
    srv.listen(20)
    print(f"[*] Servidor HTTP limitado en :80 (max {MAX_WORKERS} conexiones activas)")
    while True:
        client, _ = srv.accept()
        threading.Thread(target=_handle, args=(client,), daemon=True).start()


if __name__ == "__main__":
    main()
