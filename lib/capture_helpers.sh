#!/usr/bin/env bash
# Helpers for clean terminal-style capture (setup silent, action visible).
set -euo pipefail

if [[ -z "${ROOT:-}" ]]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

SETUP_LOG="${ROOT}/report/setup.log"
HOST_USER="${HOST_USER:-oscar}"
HOST_NAME="${HOST_NAME:-lab}"

COMPOSE=""
COMPOSE_PROJECT=""
COMPOSE_FILE="docker-compose.yml"

init_compose() {
  COMPOSE_PROJECT="$1"
  COMPOSE_FILE="${2:-docker-compose.yml}"
  COMPOSE="docker compose -p ${COMPOSE_PROJECT} -f ${COMPOSE_FILE}"
  mkdir -p "${ROOT}/report"
}

_setup_log() {
  echo "" >> "${SETUP_LOG}"
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') ${COMPOSE_PROJECT} ===" >> "${SETUP_LOG}"
}

setup_lab() {
  _setup_log
  ${COMPOSE} down -v >> "${SETUP_LOG}" 2>&1 || true
  ${COMPOSE} up -d --build >> "${SETUP_LOG}" 2>&1
}

teardown_lab() {
  ${COMPOSE} down -v >> "${SETUP_LOG}" 2>&1 || true
}

section() {
  local num="$1" title="$2" mode="$3"
  printf '\n'
  echo "╔══════════════════════════════════════════════════════════════╗"
  printf '║  Taller 2 — Punto %s — %-28s ║\n' "${num}" "${title}"
  printf '║  Modo: %-53s ║\n' "${mode}"
  echo "╚══════════════════════════════════════════════════════════════╝"
  printf '\n'
}

_prompt() {
  local role="$1" ip="$2" sym="$3" cmd="$4"
  echo "${HOST_USER}@${HOST_NAME} ${sym} [${role} ${ip}]"
  echo "${cmd}"
}

prompt_attack() {
  _prompt "ATACANTE" "$1" "\$" "$2"
}

prompt_server() {
  _prompt "SERVIDOR/VÍCTIMA" "$1" "#" "$2"
}

prompt_client() {
  _prompt "CLIENTE" "$1" "\$" "$2"
}

prompt_victim() {
  _prompt "VÍCTIMA" "$1" "#" "$2"
}

run_exec() {
  local service="$1"
  shift
  ${COMPOSE} exec -T "${service}" "$@" 2>&1 || true
}

run_exec_host() {
  # Run on host but show as if local (for dig etc. from attacker container)
  run_exec "$@"
}

blank_line() {
  echo ""
}

export ROOT SETUP_LOG HOST_USER HOST_NAME
