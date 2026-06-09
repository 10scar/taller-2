# 04 — Idle / Zombie scan (LAN)

El servidor añade una IP alias `.250` en la misma interfaz para el zombie.

## Servidor

```bash
./servidor.sh
```

Anota las dos IPs que imprime (objetivo y zombie).

## Atacante

```bash
sudo ./atacante.sh <IP_OBJETIVO> <IP_ZOMBIE>
```

Esperado: `Puerto 8080/tcp ABIERTO`
