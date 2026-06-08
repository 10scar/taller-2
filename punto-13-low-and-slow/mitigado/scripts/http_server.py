#!/usr/bin/env python3
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

class Handler(SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

print("[*] Servidor HTTP threading limitado en :80")
ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()
