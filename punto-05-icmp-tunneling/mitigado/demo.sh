#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 05 — ICMP TUNNELING [MITIGADO] =========="
P="docker compose -p p05m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
MSG="MensajeSecretoTunelizado"
$P down -v 2>/dev/null || true
$P up -d --build
sleep 4
$P exec -d receptor sh -c 'python3 /lab/recv_icmp.py > /tmp/demo.log 2>&1'
sleep 2
$P exec emisor python3 /lab/send_icmp.py 10.9.0.102 "$MSG"
sleep 6
$P exec receptor cat /tmp/demo.log 2>/dev/null || true
$P down -v
