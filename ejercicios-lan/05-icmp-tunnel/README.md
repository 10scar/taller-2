# 05 — Tunelización ICMP (LAN)

## Vulnerable

```bash
./servidor.sh
sudo ./atacante.sh <IP_SERVIDOR> "Hola tunel ICMP"
```

Esperado en servidor: mensaje extraído del payload.

## Mitigado

`iptables` DROP ICMP echo-request con length ≥ 85.

```bash
./servidor-mitigado.sh
sudo ./atacante.sh <IP_SERVIDOR> "Hola tunel ICMP"
```

Esperado: el receptor no muestra el mensaje (paquete bloqueado).
