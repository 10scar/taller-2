# Punto 03 — TCP Session Hijacking (Challenge ACK Side-Channel)

Canal colateral CVE-2016-5696: el atacante off-path deduce información de secuencia probando SYN fuera de ventana.

## Topología interna

| Rol | IP | Puerto expuesto al host |
|-----|-----|-------------------------|
| Servidor | 10.9.0.5 | `9999` → `:9999` |
| Cliente | 10.9.0.6 | — |
| Atacante | 10.9.0.7 | — |

El atacante remoto mantiene la sesión con `nc <IP_HOST> 9999` y lanza el probe Scapy **desde su PC**.

Guía del atacante: **[README-ATACANTE.md](README-ATACANTE.md)**

## Levantar laboratorio vulnerable

```bash
cd vulnerable
docker compose up -d --build
sudo ../../lib/lan-expose.sh
```

Comprueba:

```bash
echo test | nc -w 2 localhost 9999
ip -4 route get 1.1.1.1 | awk '{for (i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'
```

### Firewall (Fedora)

```bash
sudo firewall-cmd --add-port=9999/tcp
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
sudo firewall-cmd --remove-port=9999/tcp
```

## Salida esperada

| Modo | Probe Challenge ACK |
|------|---------------------|
| Vulnerable | `CANAL COLATERAL ACTIVO: respuestas diferenciadas` |
| Mitigado | `Respuestas uniformes — side-channel mitigado` |
