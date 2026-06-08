#!/usr/bin/env python3
import http.server
import os

os.chdir("/tmp")
with open("/tmp/bigfile.bin", "wb") as f:
    f.write(os.urandom(5 * 1024 * 1024))
print("[*] Sirviendo /tmp en :80 (bigfile.bin 5MB)")
http.server.HTTPServer(("0.0.0.0", 80), http.server.SimpleHTTPRequestHandler).serve_forever()
