#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 12 — DOWNGRADE TLS [VULNERABLE] =========="
P="docker compose -p p12v -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 4
$P exec servidor sh -c 'echo | openssl s_client -connect 127.0.0.1:443 -tls1 2>&1' | grep -E "Protocol|Cipher|Verify|CONNECTED|error|alert" || true
$P down -v
