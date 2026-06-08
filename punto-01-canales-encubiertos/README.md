# Punto 01 — Canales Encubiertos en Cabeceras

Codifica un mensaje en el campo **IP ID** de paquetes ICMP y lo decodifica en el receptor.

## Vulnerable

```bash
cd vulnerable
docker compose up -d --build
docker compose exec emisor python3 /lab/encode_headers.py 10.9.0.102 SECRETO
docker compose exec receptor python3 /lab/decode_headers.py
docker compose down -v
```

## Mitigado

Normalización de cabeceras: filtro de patrones IP ID encubiertos (RFC 6528).

```bash
cd mitigado && ./demo.sh
```

## Salida esperada

- **Vulnerable**: `MENSAJE DECODIFICADO: SECRETO`
- **Mitigado**: `Canal encubierto destruido — sin datos recuperables`
