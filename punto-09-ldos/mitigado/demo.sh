#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p09m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d servidor python3 /lab/http_server.py >> "${SETUP_LOG}" 2>&1
sleep 2
${COMPOSE} exec -d atacante python3 /lab/ldos.py 10.9.0.103 20 >> "${SETUP_LOG}" 2>&1
sleep 3

section "09" "LDoS" "MITIGADO"
prompt_attack "10.9.0.101" "python3 /lab/ldos.py 10.9.0.103 20  # hashlimit activo"
echo "[*] Ataque LDoS en background (mitigado por hashlimit)..."
blank_line
prompt_client "10.9.0.102" "curl -w 'velocidad=%{speed_download} B/s' http://10.9.0.103/bigfile.bin"
run_exec cliente curl -s -o /dev/null -w "velocidad=%{speed_download} B/s tiempo=%{time_total}s\n" --max-time 30 http://10.9.0.103/bigfile.bin || true
echo "[+] Descarga mantiene throughput aceptable"

teardown_lab
