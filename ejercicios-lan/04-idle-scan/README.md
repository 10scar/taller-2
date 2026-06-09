# 04 — Idle / Zombie scan (LAN)

El servidor añade IP alias `.250` para el zombie.

## Vulnerable

```bash
./servidor.sh
sudo ./atacante.sh <IP_OBJETIVO> <IP_ZOMBIE>
```

Esperado: `Puerto 8080/tcp ABIERTO` (delta ≥ 1)

## Mitigado

`rp_filter=1` en el objetivo.

```bash
./servidor-mitigado.sh
sudo ./atacante.sh <IP_OBJETIVO> <IP_ZOMBIE>
```

Esperado: `delta=0`, puerto no inferible.
