#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p06v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
sleep 6

section "06" "DNS CACHE POISONING" "VULNERABLE"
prompt_attack "10.9.0.153" "dig @10.9.0.53 test.ejemplo.com +short  # consulta legítima"
run_exec atacante dig @10.9.0.53 test.ejemplo.com +short +time=2
blank_line
prompt_attack "10.9.0.153" "python3 /lab/dns_poison.py rand001 100"
${COMPOSE} exec -d atacante sh -c 'dig @10.9.0.53 rand001.ejemplo.com +time=1 +tries=1 >/dev/null 2>&1' >> "${SETUP_LOG}" 2>&1 || true
run_exec atacante python3 /lab/dns_poison.py rand001 100
sleep 2
blank_line
prompt_server "10.9.0.53" "dig @10.9.0.53 test.ejemplo.com +short  # tras envenenamiento"
run_exec atacante dig @10.9.0.53 test.ejemplo.com +short +time=2

teardown_lab
