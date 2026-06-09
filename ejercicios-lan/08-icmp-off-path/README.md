# 08 — ICMP off-path / PMTU (LAN)

Servidor y víctima corren en el **mismo host**. El atacante usa solo la IP LAN.

## Servidor

```bash
./servidor.sh
```

## Atacante

```bash
curl http://<IP_SERVIDOR>:8080/
sudo ./atacante.sh <IP_SERVIDOR>
```

## Verificar (servidor, tras el ataque)

```bash
ip route get <IP_SERVIDOR>
```

Vulnerable: aparece `mtu 576`.
