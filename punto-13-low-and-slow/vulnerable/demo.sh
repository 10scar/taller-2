#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 13 — LOW-AND-SLOW [VULNERABLE] =========="
P="docker compose -p p13v -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
$P exec -d servidor python3 /lab/limited_server.py
sleep 2
$P exec -d atacante python3 /lab/slow_attack.py 10.9.0.100 8
sleep 4
echo "[*] Cliente legítimo (puede timeout):"
set +e
$P exec cliente curl -s -o /dev/null -w "http_code=%{http_code} time=%{time_total}s\n" --max-time 5 http://10.9.0.100/
rc=$?
set -e
if [ $rc -ne 0 ]; then
  echo "[!] Timeout/fallo — servidor saturado por Slowloris"
else
  echo "[-] Conexión exitosa (servidor no saturado)"
fi
$P down -v
