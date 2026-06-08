#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p12v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
sleep 4

section "12" "DOWNGRADE TLS" "VULNERABLE"
prompt_client "10.9.0.102" "openssl s_client -connect 10.9.0.103:443 -tls1"
run_exec cliente sh -c 'echo | openssl s_client -connect 10.9.0.103:443 -tls1 2>&1' | grep -E "Protocol|Cipher|Verify|CONNECTED|error|alert|handshake" || true
blank_line
prompt_server "10.9.0.103" "# Servidor acepta TLS 1.0 / ciphers débiles"
echo "[!] Negociación insegura posible — downgrade exitoso"

teardown_lab
