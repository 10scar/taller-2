# Punto 01 — Canales Encubiertos en Cabeceras

Codifica un mensaje en el campo **IP ID** de paquetes ICMP y lo decodifica en el receptor.

| Rol | Servicio | IP |
|-----|----------|-----|
| Emisor (atacante) | `emisor` | `10.9.0.101` |
| Receptor (víctima) | `receptor` | `10.9.0.102` |

## Vulnerable (local)

```bash
cd vulnerable
docker compose up -d --build
docker compose exec emisor python3 /lab/encode_headers.py 10.9.0.102 SECRETO
docker compose exec receptor python3 /lab/decode_headers.py
docker compose down -v
```

## Mitigado

```bash
cd mitigado && ./demo.sh
```

## Acceso remoto sin SSH

### Operador (host)

```bash
cd vulnerable
docker compose up -d --build
sudo ../../lib/lan-expose.sh
```

Comparte tu IP LAN. Para ver la decodificación en el receptor:

```bash
docker compose exec receptor python3 /lab/decode_headers.py
```

### Atacante remoto (su PC)

```bash
sudo ip route add 10.9.0.0/24 via <IP_HOST>
pip install scapy
cd punto-01-canales-encubiertos/vulnerable/scripts
sudo python3 encode_headers.py 10.9.0.102 SECRETO
```

El operador ejecuta el decode en el receptor y muestra `MENSAJE DECODIFICADO: SECRETO`.

### Al terminar

```bash
sudo ../../lib/lan-expose.sh teardown
docker compose down -v
```

## Salida esperada

- **Vulnerable**: `MENSAJE DECODIFICADO: SECRETO`
- **Mitigado**: `Canal encubierto destruido — sin datos recuperables`
