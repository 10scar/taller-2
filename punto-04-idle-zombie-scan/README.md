# Punto 04 — Idle Scan / Zombie Scan

Escaneo ciego de puertos usando el IP ID predecible de un host zombie.

## Topología interna

| Rol | IP | Puerto expuesto al host |
|-----|-----|-------------------------|
| Atacante | 10.9.0.100 | — |
| Zombie | 10.9.0.150 | — |
| Objetivo | 10.9.0.200 | `8080` → `:80` |

El atacante remoto ejecuta `idle_scan.py` **desde su PC** con Scapy.

Guía del atacante: **[README-ATACANTE.md](README-ATACANTE.md)**

## Levantar laboratorio vulnerable

```bash
cd vulnerable
docker compose up -d --build
sudo ../../lib/lan-expose.sh
```

Comprueba:

```bash
echo test | nc -w 2 localhost 8080
ip -4 route get 1.1.1.1 | awk '{for (i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'
```

### Firewall (Fedora)

```bash
sudo firewall-cmd --add-port=8080/tcp
```

## Demo automática

```bash
cd vulnerable && ./demo.sh
```

## Versión mitigada

```bash
cd mitigado
docker compose up -d --build
sudo ../../lib/lan-expose.sh
```

## Apagar

```bash
sudo ../../lib/lan-expose.sh teardown
docker compose down -v
sudo firewall-cmd --remove-port=8080/tcp
```

## Salida esperada

| Modo | Delta IP ID zombie | Puerto 80 |
|------|-------------------|-----------|
| Vulnerable | ≥ 1 | ABIERTO |
| Mitigado | 0 | No inferible |
