#!/usr/bin/env python3
"""Generate HTML (and optional PDF) report from lab results."""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
from datetime import datetime, timezone
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPORT_DIR = ROOT / "report"
ASSETS_DIR = REPORT_DIR / "assets"
RESULTS_JSON = REPORT_DIR / "results.json"
METADATA_JSON = Path(__file__).resolve().parent / "labs_metadata.json"
HTML_OUT = REPORT_DIR / "informe-taller2.html"
PDF_OUT = REPORT_DIR / "informe-taller2.pdf"


def load_json(path: Path) -> dict | list:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def copy_assets(results: dict, metadata_by_id: dict) -> None:
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    for lab_id, lab in results.get("labs", {}).items():
        for mode in ("vulnerable", "mitigado"):
            info = lab.get(mode, {})
            src = info.get("screenshot")
            if not src or not Path(src).is_file():
                continue
            dest = ASSETS_DIR / f"punto-{lab_id}-{mode}.png"
            shutil.copy2(src, dest)
            info["asset"] = f"assets/punto-{lab_id}-{mode}.png"


def img_block(asset: str | None, label: str) -> str:
    if not asset:
        return f'<div class="shot missing"><p>{escape(label)}: captura no disponible</p></div>'
    return f"""<div class="shot">
  <h4>{escape(label)}</h4>
  <a href="{escape(asset)}" target="_blank"><img src="{escape(asset)}" alt="{escape(label)}"/></a>
</div>"""


def build_html(results: dict, metadata: list) -> str:
    metadata_by_id = {m["id"]: m for m in metadata}
    copy_assets(results, metadata_by_id)
    generated = results.get("generated_at") or datetime.now(timezone.utc).isoformat()

    toc = []
    sections = []

    for meta in metadata:
        lab_id = meta["id"]
        lab_result = results.get("labs", {}).get(lab_id, {})
        v = lab_result.get("vulnerable", {})
        m = lab_result.get("mitigado", {})
        v_status = v.get("status", "pending")
        m_status = m.get("status", "pending")
        anchor = f"punto-{lab_id}"

        toc.append(
            f'<li><a href="#{anchor}">Punto {lab_id} — {escape(meta["title"])}</a>'
            f' <span class="badge {"ok" if v_status=="ok" and m_status=="ok" else "fail"}">'
            f'{"OK" if v_status=="ok" and m_status=="ok" else "FAIL"}</span></li>'
        )

        capture_text = ""
        cap_path = v.get("capture")
        if cap_path and Path(cap_path).is_file():
            capture_text = Path(cap_path).read_text(encoding="utf-8", errors="replace")[-2000:]

        sections.append(f"""
<section id="{anchor}" class="lab-section">
  <h2>Punto {lab_id} — {escape(meta["title"])}</h2>
  <div class="meta">
    <span><strong>Protocolo:</strong> {escape(meta["protocol"])}</span>
    <span><strong>Capa:</strong> {escape(meta["layer"])}</span>
    <span><strong>Criticidad:</strong> {escape(meta["cvss"])}</span>
  </div>
  <h3>Descripción de la vulnerabilidad</h3>
  <p>{escape(meta["description"])}</p>
  <h3>Escenario de laboratorio</h3>
  <p>{escape(meta["scenario"])}</p>
  <h3>Mitigación aplicada</h3>
  <p>{escape(meta["mitigation"])}</p>
  <div class="compare">
    {img_block(v.get("asset"), "Estado vulnerable")}
    {img_block(m.get("asset"), "Estado mitigado")}
  </div>
  <div class="explain-grid">
    <div><h4>Vulnerable</h4><p>{escape(meta["vulnerable_explain"])}</p></div>
    <div><h4>Mitigado</h4><p>{escape(meta["mitigado_explain"])}</p></div>
  </div>
  <h3>Comandos de demostración</h3>
  <pre><code>{escape(meta["commands"])}</code></pre>
  <details><summary>Salida capturada (vulnerable)</summary><pre>{escape(capture_text)}</pre></details>
</section>
""")

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Taller 2 — Informe de Vulnerabilidades TCP/IP</title>
<style>
:root {{ --bg:#0f1117; --card:#1a1d27; --text:#e6e8ec; --muted:#9aa3b2; --accent:#6ea8fe; --ok:#3dd68c; --fail:#f07178; }}
* {{ box-sizing:border-box; }}
body {{ margin:0; font-family:Segoe UI, system-ui, sans-serif; background:var(--bg); color:var(--text); line-height:1.55; }}
header {{ padding:2rem; background:linear-gradient(135deg,#1e3a5f,#0f1117); border-bottom:1px solid #2a3142; }}
header h1 {{ margin:0 0 .5rem; font-size:1.8rem; }}
header p {{ margin:.25rem 0; color:var(--muted); }}
main {{ max-width:1200px; margin:0 auto; padding:1.5rem; }}
nav {{ background:var(--card); padding:1rem 1.5rem; border-radius:10px; margin-bottom:2rem; }}
nav ul {{ columns:2; margin:0; padding-left:1.2rem; }}
nav a {{ color:var(--accent); text-decoration:none; }}
.badge {{ font-size:.75rem; padding:.1rem .45rem; border-radius:4px; margin-left:.3rem; }}
.badge.ok {{ background:#1a3d2e; color:var(--ok); }}
.badge.fail {{ background:#3d1a1f; color:var(--fail); }}
.lab-section {{ background:var(--card); border-radius:12px; padding:1.5rem; margin-bottom:2rem; border:1px solid #2a3142; }}
.lab-section h2 {{ margin-top:0; color:var(--accent); border-bottom:1px solid #2a3142; padding-bottom:.5rem; }}
.meta {{ display:flex; flex-wrap:wrap; gap:1rem; color:var(--muted); font-size:.9rem; margin-bottom:1rem; }}
.compare {{ display:grid; grid-template-columns:1fr 1fr; gap:1rem; margin:1rem 0; }}
.shot img {{ max-width:100%; border:1px solid #333; border-radius:6px; background:#000; }}
.shot.missing {{ padding:2rem; text-align:center; color:var(--muted); border:1px dashed #444; border-radius:6px; }}
.explain-grid {{ display:grid; grid-template-columns:1fr 1fr; gap:1rem; }}
pre {{ background:#0a0c10; padding:1rem; border-radius:8px; overflow:auto; font-size:.85rem; }}
footer {{ text-align:center; padding:2rem; color:var(--muted); font-size:.85rem; }}
@media (max-width:800px) {{ .compare, .explain-grid, nav ul {{ columns:1; grid-template-columns:1fr; }} }}
</style>
</head>
<body>
<header>
  <h1>Taller 2 — Auditoría de Vulnerabilidades TCP/IP</h1>
  <p>Universidad Nacional de Colombia · Facultad de Ingeniería · 2026-1S</p>
  <p>Informe generado: {escape(generated)}</p>
</header>
<main>
<nav><h3>Índice</h3><ul>{"".join(toc)}</ul></nav>
{"".join(sections)}
</main>
<footer>Generado automáticamente por run_all.sh · Taller 2 Docker Labs</footer>
</body>
</html>"""


def try_pdf(html_path: Path, pdf_path: Path) -> bool:
    try:
        from weasyprint import HTML  # type: ignore

        HTML(filename=str(html_path)).write_pdf(str(pdf_path))
        return True
    except Exception:
        pass
    try:
        subprocess.run(
            ["wkhtmltopdf", str(html_path), str(pdf_path)],
            check=True,
            capture_output=True,
        )
        return True
    except Exception:
        return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--only-report", action="store_true")
    args = parser.parse_args()

    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    if not RESULTS_JSON.is_file():
        stub = {"generated_at": datetime.now(timezone.utc).isoformat(), "labs": {}}
        RESULTS_JSON.write_text(json.dumps(stub, indent=2), encoding="utf-8")

    results = load_json(RESULTS_JSON)
    metadata = load_json(METADATA_JSON)
    html = build_html(results, metadata)
    HTML_OUT.write_text(html, encoding="utf-8")
    print(f"Informe HTML: {HTML_OUT}")

    if try_pdf(HTML_OUT, PDF_OUT):
        print(f"Informe PDF:  {PDF_OUT}")
    else:
        print("PDF no generado — instalar weasyprint o wkhtmltopdf")


if __name__ == "__main__":
    main()
