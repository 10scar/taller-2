#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 03 — TCP SESSION HIJACKING [MITIGADO] =========="
P="docker compose -p p03m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 5
$P exec -d cliente sh -c 'echo sesion-activa | nc -w 30 10.9.0.5 9999' || true &
sleep 2
$P exec atacante python3 /lab/challenge_ack_probe.py 10.9.0.5 10.9.0.6
sleep 2
$P down -v
