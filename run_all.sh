#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "${ROOT}/lib/common.sh"

NO_REPORT=0
SELECTED=()

usage() {
  echo "Uso: $0 [--no-report] [NN ...]"
  echo "  Sin argumentos: ejecuta los 13 puntos"
  echo "  NN: solo punto específico (ej. 5)"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-report) NO_REPORT=1; shift ;;
    -h|--help) usage ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        SELECTED+=("$(printf '%02d' "$1")")
      else
        echo "Argumento desconocido: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

exec > >(tee -a "${REPORT_DIR}/run.log") 2>&1

log "=== Taller 2 — Inicio ==="
init_results

declare -A LABS=(
  [01]="canales-encubiertos"
  [02]="canales-temporizacion"
  [03]="tcp-session-hijacking"
  [04]="idle-zombie-scan"
  [05]="icmp-tunneling"
  [06]="dns-cache-poisoning"
  [07]="fragmentacion-ip"
  [08]="icmp-off-path"
  [09]="ldos"
  [10]="slow-dns-exfiltration"
  [11]="arp-spoofing"
  [12]="downgrade-tls"
  [13]="low-and-slow"
)

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  SELECTED=(01 02 03 04 05 06 07 08 09 10 11 12 13)
fi

overall=0
for num in "${SELECTED[@]}"; do
  slug="${LABS[$num]:-}"
  if [[ -z "${slug}" ]]; then
    log "Punto desconocido: ${num}"
    overall=1
    continue
  fi
  run_lab "${num}" "${slug}" || overall=1
done

if [[ ${NO_REPORT} -eq 0 ]]; then
  generate_report || true
fi

print_summary || overall=1
exit "${overall}"
