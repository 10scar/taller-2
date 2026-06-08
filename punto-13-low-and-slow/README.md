# Punto 13 — Ataques Low-and-Slow (Slowloris)

Conexiones HTTP incompletas que agotan el pool de threads del servidor.

## Topología

| Rol | IP |
|-----|-----|
| Atacante | 10.9.0.11 |
| Servidor | 10.9.0.100 |
| Cliente legítimo | 10.9.0.12 |

## Mitigación

`iptables connlimit --connlimit-above 10` limita conexiones SYN concurrentes por IP. El servidor usa `limited_server.py` con pool de 3 workers; el demo refuerza el límite sobre la IP del atacante (10.9.0.11).
