# Punto 08 — Ataques Off-Path con ICMP Forjado

Demuestra ICMP Type 3 Code 4 forjado con MTU reducido que altera la caché PMTU de la víctima.

## Topología

| Rol | IP |
|-----|-----|
| Atacante | 10.9.0.10 |
| Víctima | 10.9.0.20 |
| Servidor TCP | 10.9.0.30 |

## Mitigación

`accept_redirects=0` y `tcp_mtu_probing=1` en la víctima evitan degradación persistente.
