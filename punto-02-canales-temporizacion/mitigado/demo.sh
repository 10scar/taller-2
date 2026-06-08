#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p02m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d receptor sh -c 'python3 /lab/timing_recv.py 10.9.0.101 > /tmp/demo.log 2>&1' >> "${SETUP_LOG}" 2>&1
sleep 2

section "02" "CANALES TEMPORIZACIÓN" "MITIGADO"
prompt_attack "10.9.0.101" "python3 /lab/timing_send.py 10.9.0.102 1010"
run_exec emisor python3 /lab/timing_send.py 10.9.0.102 1010
sleep 8
blank_line
prompt_server "10.9.0.102" "cat /tmp/demo.log  (jitter activo en gateway)"
run_exec receptor cat /tmp/demo.log 2>/dev/null || true

teardown_lab
