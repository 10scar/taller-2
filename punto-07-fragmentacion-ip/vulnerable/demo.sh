#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 07 — FRAGMENTACIÓN IP [VULNERABLE] =========="
P="docker compose -p p07v -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
$P exec -d objetivo python3 /lab/fragment_detect.py
sleep 1
$P exec atacante python3 /lab/fragment_attack.py 10.9.0.102
sleep 4
$P logs objetivo 2>/dev/null || true
$P down -v
