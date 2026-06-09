#!/usr/bin/env bash
# Expone la subred Docker 10.9.0.0/24 a la LAN vía enrutamiento en el host.
set -euo pipefail

LAB_SUBNET="10.9.0.0/24"
STATE_DIR="/var/tmp/taller2-lan-expose"
STATE_FILE="${STATE_DIR}/state.env"

usage() {
  cat <<'EOF'
Uso: sudo ./lan-expose.sh [teardown]

  (sin args)  Habilita reenvío IP para que clientes LAN alcancen 10.9.0.0/24
  teardown    Elimina reglas y restaura configuración guardada

Requisito previo: docker compose up -d en el laboratorio activo
EOF
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Este script debe ejecutarse con sudo." >&2
    exit 1
  fi
}

detect_lan() {
  local route_line dev ip
  route_line="$(ip -4 route get 1.1.1.1 2>/dev/null || true)"
  if [[ -z "${route_line}" ]]; then
    echo "No se pudo detectar la interfaz LAN (sin ruta por defecto)." >&2
    exit 1
  fi
  dev="$(awk '{for (i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}' <<<"${route_line}")"
  ip="$(awk '{for (i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}' <<<"${route_line}")"
  if [[ -z "${dev}" || -z "${ip}" ]]; then
    echo "No se pudo parsear interfaz/IP LAN desde: ${route_line}" >&2
    exit 1
  fi
  LAN_IF="${dev}"
  LAN_IP="${ip}"
}

detect_lab_bridge() {
  local net_id bridge
  net_id="$(docker network ls --filter "driver=bridge" --format '{{.ID}} {{.Name}}' \
    | while read -r id name; do
        docker network inspect "${id}" --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null \
          | grep -qx "${LAB_SUBNET}" && { echo "${id}"; break; }
      done)"
  if [[ -z "${net_id}" ]]; then
    echo "No se encontró red Docker con subred ${LAB_SUBNET}." >&2
    echo "Levanta el laboratorio primero: docker compose up -d --build" >&2
    exit 1
  fi
  bridge="$(docker network inspect "${net_id}" --format '{{index .Options "com.docker.network.bridge.name"}}')"
  if [[ -z "${bridge}" ]]; then
    bridge="$(docker network inspect "${net_id}" --format '{{.Id}}' | cut -c1-12)"
    bridge="br-${bridge}"
  fi
  if ! ip link show "${bridge}" &>/dev/null; then
    echo "Bridge Docker '${bridge}' no existe en el host." >&2
    exit 1
  fi
  LAB_BRIDGE="${bridge}"
  LAB_NET_ID="${net_id}"
}

save_state() {
  mkdir -p "${STATE_DIR}"
  local fwd
  fwd="$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)"
  cat >"${STATE_FILE}" <<EOF
LAN_IF=${LAN_IF}
LAN_IP=${LAN_IP}
LAB_BRIDGE=${LAB_BRIDGE}
LAB_NET_ID=${LAB_NET_ID}
PREV_IP_FORWARD=${fwd}
EOF
}

apply_firewalld() {
  if ! command -v firewall-cmd &>/dev/null; then
    return 0
  fi
  if ! systemctl is-active --quiet firewalld 2>/dev/null; then
    return 0
  fi
  firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i "${LAN_IF}" -o "${LAB_BRIDGE}" -j ACCEPT \
    >/dev/null 2>&1 || true
  firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i "${LAB_BRIDGE}" -o "${LAN_IF}" -m state --state RELATED,ESTABLISHED -j ACCEPT \
    >/dev/null 2>&1 || true
  firewall-cmd --reload >/dev/null 2>&1 || true
  echo "firewalld" >"${STATE_DIR}/firewalld-applied"
}

apply_iptables() {
  if command -v iptables &>/dev/null; then
    iptables -C FORWARD -i "${LAN_IF}" -o "${LAB_BRIDGE}" -j ACCEPT 2>/dev/null \
      || iptables -I FORWARD 1 -i "${LAN_IF}" -o "${LAB_BRIDGE}" -j ACCEPT
    iptables -C FORWARD -i "${LAB_BRIDGE}" -o "${LAN_IF}" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
      || iptables -I FORWARD 2 -i "${LAB_BRIDGE}" -o "${LAN_IF}" -m state --state RELATED,ESTABLISHED -j ACCEPT
    echo "iptables" >"${STATE_DIR}/iptables-applied"
  fi
}

setup() {
  require_root
  detect_lan
  detect_lab_bridge
  save_state

  sysctl -w net.ipv4.ip_forward=1 >/dev/null
  apply_iptables
  apply_firewalld

  cat <<EOF

=== Laboratorio 10.9.0.0/24 expuesto a la LAN ===
Host LAN:     ${LAN_IP} (${LAN_IF})
Bridge lab:   ${LAB_BRIDGE}
Subred lab:   ${LAB_SUBNET}

En cada PC atacante de la red (Linux/macOS):
  sudo ip route add 10.9.0.0/24 via ${LAN_IP}
  ping -c 2 10.9.0.10    # ejemplo punto 08 atacante
  pip install scapy
  sudo python3 <script_de_ataque>.py ...

Windows (CMD como administrador):
  route add 10.9.0.0 mask 255.255.255.0 ${LAN_IP}

Al terminar en el host:
  sudo $(realpath "$0" 2>/dev/null || echo "./lan-expose.sh") teardown
  docker compose down -v

EOF
}

teardown_firewalld() {
  if [[ ! -f "${STATE_DIR}/firewalld-applied" ]]; then
    return 0
  fi
  # shellcheck source=/dev/null
  source "${STATE_FILE}"
  firewall-cmd --permanent --direct --remove-rule ipv4 filter FORWARD 0 -i "${LAN_IF}" -o "${LAB_BRIDGE}" -j ACCEPT \
    >/dev/null 2>&1 || true
  firewall-cmd --permanent --direct --remove-rule ipv4 filter FORWARD 0 -i "${LAB_BRIDGE}" -o "${LAN_IF}" -m state --state RELATED,ESTABLISHED -j ACCEPT \
    >/dev/null 2>&1 || true
  firewall-cmd --reload >/dev/null 2>&1 || true
  rm -f "${STATE_DIR}/firewalld-applied"
}

teardown_iptables() {
  if [[ ! -f "${STATE_DIR}/iptables-applied" ]]; then
    return 0
  fi
  # shellcheck source=/dev/null
  source "${STATE_FILE}"
  iptables -D FORWARD -i "${LAN_IF}" -o "${LAB_BRIDGE}" -j ACCEPT 2>/dev/null || true
  iptables -D FORWARD -i "${LAB_BRIDGE}" -o "${LAN_IF}" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
  rm -f "${STATE_DIR}/iptables-applied"
}

teardown() {
  require_root
  if [[ ! -f "${STATE_FILE}" ]]; then
    echo "No hay estado guardado; nada que revertir."
    exit 0
  fi
  # shellcheck source=/dev/null
  source "${STATE_FILE}"
  teardown_iptables
  teardown_firewalld
  sysctl -w "net.ipv4.ip_forward=${PREV_IP_FORWARD}" >/dev/null 2>&1 || true
  rm -f "${STATE_FILE}"
  echo "Reglas de exposición LAN eliminadas."
}

main() {
  case "${1:-}" in
    ""|setup) setup ;;
    teardown) teardown ;;
    -h|--help) usage ;;
    *)
      echo "Subcomando desconocido: $1" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
