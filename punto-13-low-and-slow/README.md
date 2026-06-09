# Punto 13 — Ataques Low-and-Slow (Slowloris)

Conexiones HTTP incompletas que agotan el pool de workers del servidor.

## Topología interna

| Rol | IP | Puerto expuesto al host |
|-----|-----|-------------------------|
| Atacante | 10.9.0.11 | — |
| Servidor | 10.9.0.100 | `8080` → `:80` |
| Cliente legítimo | 10.9.0.12 | — |

El servidor se publica en **`http://<IP_LAN_DEL_HOST>:8080`**. Los compañeros en la red atacan esa URL; no necesitan Docker ni rutas especiales.

Instrucciones para el atacante remoto: **[README-ATACANTE.md](README-ATACANTE.md)**

## Levantar laboratorio vulnerable

```bash
cd vulnerable
docker compose up -d --build
docker compose exec -d servidor python3 /lab/limited_server.py
```

Comprueba que responde:

```bash
curl http://localhost:8080/
# Debe devolver: OK
```

Obtén tu IP LAN para compartirla:

```bash
ip -4 route get 1.1.1.1 | awk '{for (i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'
```

### Firewall (Fedora)

Si los compañeros no pueden conectar, abre el puerto temporalmente:

```bash
sudo firewall-cmd --add-port=8080/tcp
```

Al terminar:

```bash
sudo firewall-cmd --remove-port=8080/tcp
```

## Demo automática (capturas)

```bash
cd vulnerable && ./demo.sh
```

## Versión mitigada

`iptables connlimit` limita conexiones SYN concurrentes por IP. El servidor mantiene un pool de 3 workers.

```bash
cd mitigado
docker compose up -d --build
docker compose exec -d servidor python3 /lab/limited_server.py
```

Mismo puerto expuesto (`8080`). Repite el ataque desde otro PC siguiendo [README-ATACANTE.md](README-ATACANTE.md): el cliente legítimo (`curl`) debería seguir respondiendo.

Demo automática:

```bash
cd mitigado && ./demo.sh
```

## Apagar

```bash
docker compose down -v
```

Ejecuta en `vulnerable/` o `mitigado/` según el modo que hayas levantado.

## Salida esperada

| Modo | Ataque Slowloris (8 sockets) | Cliente `curl` |
|------|------------------------------|----------------|
| Vulnerable | Abre conexiones lentas | Timeout o fallo |
| Mitigado | Limitado por connlimit | `http_code=200` |
