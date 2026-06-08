#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 13 — LOW-AND-SLOW [MITIGADO] =========="
P="docker compose -p p13m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
$P exec -d servidor python3 /lab/limited_server.py
sleep 2
$P exec -d atacante python3 /lab/slow_attack.py 10.9.0.100 8
sleep 4
echo "[*] Cliente legítimo (debería conectar):"
$P exec cliente curl -s -o /dev/null -w "http_code=%{http_code} time=%{time_total}s\n" --max-time 8 http://10.9.0.100/
$P down -v
