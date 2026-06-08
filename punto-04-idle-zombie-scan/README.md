# Punto 04 — Idle Scan / Zombie Scan

Escaneo ciego de puertos usando IP ID predecible de un host zombie.

## Topología

| Host     | IP          | Rol                         |
|----------|-------------|-----------------------------|
| Atacante | 10.9.0.100  | idle_scan.py (IP spoofing)  |
| Zombie   | 10.9.0.150  | zombie.py (IP ID incremental)|
| Objetivo | 10.9.0.200  | Puerto 80 abierto           |

## Ejecución

```bash
cd vulnerable && chmod +x demo.sh && ./demo.sh
cd ../mitigado && chmod +x demo.sh && ./demo.sh
```

- **Vulnerable**: delta IP ID ≥ 1 indica puerto 80 abierto.
- **Mitigado**: `rp_filter=1` bloquea SYN spoofed; delta = 0.
