#!/usr/bin/env python3
import socket

s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 8080))
s.listen(5)
print("[*] Servidor TCP escuchando en :8080")
while True:
    c, addr = s.accept()
    c.recv(4096)
    c.send(b"HTTP/1.0 200 OK\r\nContent-Length: 2\r\n\r\nOK")
    c.close()
