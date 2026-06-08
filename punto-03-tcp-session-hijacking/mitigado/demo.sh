#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p03m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d cliente sh -c 'echo sesion-activa | nc -w 30 10.9.0.5 9999' >> "${SETUP_LOG}" 2>&1 || true
sleep 2

section "03" "TCP SESSION HIJACKING" "MITIGADO"
prompt_attack "10.9.0.7" "python3 /lab/challenge_ack_probe.py 10.9.0.5 10.9.0.6"
run_exec atacante python3 /lab/challenge_ack_probe.py 10.9.0.5 10.9.0.6
blank_line
prompt_server "10.9.0.5" "# tcp_challenge_ack_limit=2147483647"
echo "[+] Respuestas uniformes — canal colateral neutralizado"

teardown_lab
