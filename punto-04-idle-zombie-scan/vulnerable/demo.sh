#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p04v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
sleep 3

section "04" "IDLE ZOMBIE SCAN" "VULNERABLE"
prompt_attack "10.9.0.100" "python3 /lab/idle_scan.py 10.9.0.150 10.9.0.200 80"
run_exec atacante python3 /lab/idle_scan.py 10.9.0.150 10.9.0.200 80
blank_line
prompt_server "10.9.0.200" "# Puerto 80 — estado inferido por delta IP ID del zombie"
echo "[*] Delta IP ID +1 indica puerto abierto sin revelar IP real del atacante"

teardown_lab
