#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 02 — CANALES TEMPORIZACIÓN [MITIGADO] =========="
P="docker compose -p p02m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 6
$P exec -d receptor sh -c 'python3 /lab/timing_recv.py 10.9.0.101 > /tmp/demo.log 2>&1'
sleep 2
$P exec emisor python3 /lab/timing_send.py 10.9.0.102 1010
sleep 10
$P exec receptor cat /tmp/demo.log 2>/dev/null || true
$P down -v
