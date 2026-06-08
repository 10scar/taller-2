#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${ROOT_DIR}/lib"
SCREENSHOTS_DIR="${ROOT_DIR}/screenshots"
REPORT_DIR="${ROOT_DIR}/report"
CAPTURES_DIR="${REPORT_DIR}/captures"
RESULTS_JSON="${REPORT_DIR}/results.json"

mkdir -p "${SCREENSHOTS_DIR}" "${REPORT_DIR}" "${CAPTURES_DIR}" "${REPORT_DIR}/assets"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

init_results() {
  python3 - <<'PY'
import json, os
from datetime import datetime, timezone
path = os.environ["RESULTS_JSON"]
data = {"generated_at": datetime.now(timezone.utc).isoformat(), "labs": {}}
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY
}

update_result() {
  local num="$1" mode="$2" status="$3" capture="$4" png="$5" duration="$6"
  RESULTS_JSON="${RESULTS_JSON}" NUM="${num}" MODE="${mode}" STATUS="${status}" \
  CAPTURE="${capture}" PNG="${png}" DURATION="${duration}" python3 - <<'PY'
import json, os
path = os.environ["RESULTS_JSON"]
with open(path) as f:
    data = json.load(f)
num = os.environ["NUM"]
mode = os.environ["MODE"]
lab = data["labs"].setdefault(num, {})
lab[mode] = {
    "status": os.environ["STATUS"],
    "capture": os.environ["CAPTURE"],
    "screenshot": os.environ["PNG"],
    "duration_sec": float(os.environ["DURATION"]),
}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY
}

run_demo_capture() {
  local num="$1" mode="$2" lab_dir="$3"
  local demo="${lab_dir}/${mode}/demo.sh"
  local capture="${CAPTURES_DIR}/punto-${num}-${mode}.txt"
  local png="${SCREENSHOTS_DIR}/punto-${num}-${mode}.png"
  local start end duration status

  if [[ ! -f "${demo}" ]]; then
    log "ERROR: demo no encontrado: ${demo}"
    return 1
  fi

  start=$(date +%s)
  log "Ejecutando punto-${num} (${mode})..."
  set +e
  (cd "${lab_dir}/${mode}" && ROOT="${ROOT_DIR}" CAPTURE_MODE=1 bash demo.sh) > "${capture}" 2>&1
  status=$?
  set -e
  end=$(date +%s)
  duration=$((end - start))

  python3 "${LIB_DIR}/render_screenshot.py" "${capture}" "${png}"

  if [[ ${status} -eq 0 ]]; then
    update_result "${num}" "${mode}" "ok" "${capture}" "${png}" "${duration}"
    log "punto-${num} ${mode}: OK (${duration}s)"
  else
    update_result "${num}" "${mode}" "fail" "${capture}" "${png}" "${duration}"
    log "punto-${num} ${mode}: FAIL (${duration}s)"
  fi
  return "${status}"
}

run_lab() {
  local num="$1" slug="$2"
  local lab_dir="${ROOT_DIR}/punto-${num}-${slug}"
  local vuln_status=0 mit_status=0

  if [[ ! -d "${lab_dir}" ]]; then
    log "ERROR: carpeta inexistente ${lab_dir}"
    return 1
  fi

  run_demo_capture "${num}" "vulnerable" "${lab_dir}" || vuln_status=$?
  run_demo_capture "${num}" "mitigado" "${lab_dir}" || mit_status=$?

  if [[ ${vuln_status} -ne 0 || ${mit_status} -ne 0 ]]; then
    return 1
  fi
  return 0
}

generate_report() {
  python3 "${LIB_DIR}/generate_report.py"
}

print_summary() {
  python3 - <<'PY'
import json, os
path = os.environ["RESULTS_JSON"]
with open(path) as f:
    data = json.load(f)
print("\n=== Taller 2 — Resumen ===")
failed = 0
for num in sorted(data.get("labs", {}), key=lambda x: int(x)):
    lab = data["labs"][num]
    v = lab.get("vulnerable", {}).get("status", "?")
    m = lab.get("mitigado", {}).get("status", "?")
    ok = v == "ok" and m == "ok"
    if not ok:
        failed += 1
    mark = "OK" if ok else "FAIL"
    print(f"Punto {num}: {mark}  (vulnerable {'✓' if v=='ok' else '✗'}  mitigado {'✓' if m=='ok' else '✗'})")
html = os.path.join(os.environ["REPORT_DIR"], "informe-taller2.html")
pdf = os.path.join(os.environ["REPORT_DIR"], "informe-taller2.pdf")
print(f"Informe:  {html}")
if os.path.isfile(pdf):
    print(f"PDF:      {pdf}")
else:
    print("PDF:      no generado (instalar weasyprint o wkhtmltopdf)")
raise SystemExit(1 if failed else 0)
PY
}

export ROOT_DIR LIB_DIR SCREENSHOTS_DIR REPORT_DIR CAPTURES_DIR RESULTS_JSON
