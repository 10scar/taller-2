# 07 — Fragmentación IP (LAN)

## Vulnerable

```bash
./servidor.sh
sudo ./atacante.sh <IP_SERVIDOR>
```

Esperado en servidor: `EVILPAYLOAD detectado`

## Mitigado

`iptables -t mangle -A PREROUTING -f -j DROP`

```bash
./servidor-mitigado.sh
sudo ./atacante.sh <IP_SERVIDOR>
```

Esperado: timeout, sin `EVILPAYLOAD`.
