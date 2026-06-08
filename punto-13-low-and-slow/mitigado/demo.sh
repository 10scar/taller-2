#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p13m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d servidor python3 /lab/limited_server.py >> "${SETUP_LOG}" 2>&1
sleep 2
${COMPOSE} exec -d atacante python3 /lab/slow_attack.py 10.9.0.100 8 >> "${SETUP_LOG}" 2>&1
sleep 4

section "13" "LOW-AND-SLOW" "MITIGADO"
prompt_attack "10.9.0.11" "python3 /lab/slow_attack.py 10.9.0.100 8  # connlimit activo"
echo "[*] Ataque Slowloris en background..."
blank_line
prompt_client "10.9.0.12" "curl --max-time 8 http://10.9.0.100/"
run_exec cliente curl -s -o /dev/null -w "http_code=%{http_code} time=%{time_total}s\n" --max-time 8 http://10.9.0.100/ || true
echo "[+] Cliente legítimo conecta — connlimit protege el pool"

teardown_lab
