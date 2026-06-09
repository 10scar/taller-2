# 03 — Challenge ACK side-channel (LAN)

## Servidor

```bash
./servidor.sh
```

## Atacante — terminal 1 (sesión TCP)

```bash
(echo sesion-activa; sleep 120) | nc <IP_SERVIDOR> 9999
```

## Atacante — terminal 2 (probe)

```bash
sudo ./atacante.sh <IP_SERVIDOR>
```

Esperado: `CANAL COLATERAL ACTIVO`
