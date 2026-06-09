# Punto 08 — Ataques Off-Path con ICMP Forjado

ICMP Type 3 Code 4 forjado con MTU reducido que altera la caché PMTU de la víctima.

## Topología interna

| Rol | IP | Puerto expuesto al host |
|-----|-----|-------------------------|
| Atacante | 10.9.0.10 | — |
| Víctima | 10.9.0.20 | — |
| Servidor TCP | 10.9.0.30 | `8080` → `:8080` |

El atacante remoto ejecuta **Scapy en su PC** tras enrutar `10.9.0.0/24` hacia tu host. Sin SSH.

Guía del atacante: **[README-ATACANTE.md](README-ATACANTE.md)**

## Levantar laboratorio vulnerable

```bash
cd vulnerable
docker compose up -d --build
docker compose exec -d servidor python3 /lab/tcp_server.py
docker compose exec -d victima python3 /lab/victim_demo.py 10.9.0.30 8080 14 45678
sudo ../../lib/lan-expose.sh
```

Comprueba:

```bash
curl http://localhost:8080/
ip -4 route get 1.1.1.1 | awk '{for (i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'
```

### Firewall (Fedora)

```bash
sudo firewall-cmd --add-port=8080/tcp
```

Comparte con el atacante: **tu IP LAN** + este README-ATACANTE.

### Verificar MTU tras el ataque (operador)

```bash
docker compose exec victima ip route get 10.9.0.30
```

## Demo automática

```bash
cd vulnerable && ./demo.sh
```

## Versión mitigada

```bash
cd mitigado
docker compose up -d --build
docker compose exec -d servidor python3 /lab/tcp_server.py
docker compose exec -d victima python3 /lab/victim_demo.py 10.9.0.30 8080 14 45678
sudo ../../lib/lan-expose.sh
```

## Apagar

```bash
sudo ../../lib/lan-expose.sh teardown
docker compose down -v
sudo firewall-cmd --remove-port=8080/tcp
```

## Salida esperada

| Modo | Tras ICMP forjado |
|------|-------------------|
| Vulnerable | `ip route get` muestra MTU 576 |
| Mitigado | Ruta estable, sin degradación persistente |
