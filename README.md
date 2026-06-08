# Taller 2 — Laboratorios Docker de Vulnerabilidades TCP/IP

13 laboratorios autocontenidos con versión **vulnerable** y **mitigada**, basados en el informe del PDF *Taller 2.pdf*.

## Requisitos

- Docker Engine 24+
- Docker Compose v2
- Python 3.11+ (host, para capturas e informe)
- `pip install pillow` (renderizado de pantallazos)
- Opcional: `weasyprint` o `wkhtmltopdf` (exportar PDF)

## Ejecución rápida

```bash
chmod +x run_all.sh lib/*.sh punto-*/**/demo.sh
./run_all.sh
```

Al terminar:

| Artefacto | Ruta |
|-----------|------|
| Informe HTML | `report/informe-taller2.html` |
| Informe PDF | `report/informe-taller2.pdf` (opcional) |
| Pantallazos | `screenshots/punto-NN-{vulnerable\|mitigado}.png` |
| Resultados | `report/results.json` |

Ejecutar un solo punto: `./run_all.sh 5`

Regenerar informe sin Docker: `python3 lib/generate_report.py --only-report`

## Laboratorios

| # | Carpeta | Vulnerabilidad |
|---|---------|----------------|
| 01 | [punto-01-canales-encubiertos](punto-01-canales-encubiertos/) | Canales encubiertos en cabeceras IP/TCP |
| 02 | [punto-02-canales-temporizacion](punto-02-canales-temporizacion/) | Canales por temporización (IPD) |
| 03 | [punto-03-tcp-session-hijacking](punto-03-tcp-session-hijacking/) | TCP session hijacking off-path |
| 04 | [punto-04-idle-zombie-scan](punto-04-idle-zombie-scan/) | Idle / Zombie scan |
| 05 | [punto-05-icmp-tunneling](punto-05-icmp-tunneling/) | Tunelización ICMP |
| 06 | [punto-06-dns-cache-poisoning](punto-06-dns-cache-poisoning/) | DNS cache poisoning |
| 07 | [punto-07-fragmentacion-ip](punto-07-fragmentacion-ip/) | Fragmentación IP avanzada |
| 08 | [punto-08-icmp-off-path](punto-08-icmp-off-path/) | ICMP off-path forjado |
| 09 | [punto-09-ldos](punto-09-ldos/) | Low-rate DoS (LDoS) |
| 10 | [punto-10-slow-dns-exfiltration](punto-10-slow-dns-exfiltration/) | Exfiltración lenta DNS |
| 11 | [punto-11-arp-spoofing](punto-11-arp-spoofing/) | ARP spoofing silencioso |
| 12 | [punto-12-downgrade-tls](punto-12-downgrade-tls/) | Downgrade TLS |
| 13 | [punto-13-low-and-slow](punto-13-low-and-slow/) | Low-and-Slow (Slowloris) |

## Estructura por punto

```
punto-XX-nombre/
├── README.md
├── vulnerable/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── demo.sh
│   └── scripts/
└── mitigado/
    ├── docker-compose.yml
    ├── Dockerfile
    ├── demo.sh
    └── scripts/
```

## Nota

Solo ejecutar **un laboratorio a la vez** (o usar `run_all.sh` que los encadena). Todos usan la subred `10.9.0.0/24`.
