#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 09 — LDoS [MITIGADO] =========="
P="docker compose -p p09m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
$P exec -d servidor python3 /lab/http_server.py
sleep 2
$P exec -d atacante python3 /lab/ldos.py 10.9.0.103 20
sleep 2
echo "[*] Descarga con hashlimit activo:"
$P exec cliente curl -s -o /dev/null -w "velocidad=%{speed_download} B/s tiempo=%{time_total}s\n" --max-time 30 http://10.9.0.103/bigfile.bin || true
$P down -v
