#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 04 — IDLE ZOMBIE SCAN [MITIGADO] =========="
P="docker compose -p p04m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 5
$P exec atacante python3 /lab/idle_scan.py 10.9.0.150 10.9.0.200 80
$P down -v
