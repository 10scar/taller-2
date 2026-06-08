#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p05v" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT
MSG="MensajeSecretoTunelizado"

setup_lab
${COMPOSE} exec -d receptor sh -c 'python3 /lab/recv_icmp.py > /tmp/demo.log 2>&1' >> "${SETUP_LOG}" 2>&1
sleep 2

section "05" "ICMP TUNNELING" "VULNERABLE"
prompt_attack "10.9.0.101" "python3 /lab/send_icmp.py 10.9.0.102 '${MSG}'"
run_exec emisor python3 /lab/send_icmp.py 10.9.0.102 "${MSG}"
sleep 6
blank_line
prompt_server "10.9.0.102" "cat /tmp/demo.log || tcpdump -c 1 -n 'icmp and src 10.9.0.101'"
LOG=$(${COMPOSE} exec -T receptor cat /tmp/demo.log 2>/dev/null || true)
if [[ -n "${LOG}" ]]; then
  echo "${LOG}"
else
  run_exec receptor tcpdump -c 1 -n -v icmp and src 10.9.0.101 2>/dev/null || echo "[*] Payload ICMP recibido (ver tcpdump)"
fi

teardown_lab
