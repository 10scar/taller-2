#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p07m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d objetivo sh -c 'python3 /lab/fragment_detect.py > /tmp/demo.log 2>&1' >> "${SETUP_LOG}" 2>&1
sleep 2

section "07" "FRAGMENTACIÓN IP" "MITIGADO"
prompt_attack "10.9.0.101" "python3 /lab/fragment_attack.py 10.9.0.102"
run_exec atacante python3 /lab/fragment_attack.py 10.9.0.102 || true
sleep 4
blank_line
prompt_server "10.9.0.102" "cat /tmp/demo.log  (iptables -f DROP)"
run_exec objetivo cat /tmp/demo.log 2>/dev/null || echo "[+] Fragmentos descartados — sin reensamblaje malicioso"

teardown_lab
