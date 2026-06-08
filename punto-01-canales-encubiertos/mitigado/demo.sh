#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 01 — CANALES ENCUBiertos [MITIGADO] =========="
P="docker compose -p p01m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 4
$P exec -d receptor python3 /lab/decode_headers.py
sleep 2
$P exec emisor python3 /lab/encode_headers.py 10.9.0.102 SECRETO
sleep 6
$P logs receptor 2>/dev/null || true
$P down -v
