# 03 — Challenge ACK side-channel (LAN)

## Vulnerable

```bash
./servidor.sh
```

Atacante — terminal 1: `(echo sesion-activa; sleep 120) | nc <IP> 9999`  
Atacante — terminal 2: `sudo ./atacante.sh <IP>`

Esperado: `CANAL COLATERAL ACTIVO`

## Mitigado

`tcp_challenge_ack_limit=2147483647`

```bash
./servidor-mitigado.sh
```

Mismos comandos del atacante. Esperado: `Respuestas uniformes — side-channel mitigado`
