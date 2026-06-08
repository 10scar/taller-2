# Punto 07 — Evasión IDS por Fragmentación IP

Laboratorio Docker que demuestra fragmentación IP con offsets solapados para reensamblar `EVILPAYLOAD` en UDP evadiendo inspección perimetral.

## Topología

| Rol | IP |
|-----|-----|
| Atacante | 10.9.0.101 |
| Objetivo | 10.9.0.102 |

## Uso

```bash
cd vulnerable && ./demo.sh
cd ../mitigado && ./demo.sh
```

## Mitigación

`iptables -t mangle -A PREROUTING -f -j DROP` en el objetivo descarta fragmentos IP antes del reensamblaje.
