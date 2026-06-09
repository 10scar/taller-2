# 08 — ICMP off-path / PMTU (LAN)

Servidor y víctima corren en el **mismo host**. El atacante usa solo la IP LAN.

## Vulnerable

```bash
./servidor.sh
```

## Mitigado

`accept_redirects=0` y `tcp_mtu_probing=1`. Restaura sysctl al pulsar Ctrl+C.

```bash
./servidor-mitigado.sh
```

## Atacante (vulnerable o mitigado)

```bash
curl http://<IP_SERVIDOR>:8080/
sudo ./atacante.sh <IP_SERVIDOR>
```

## Verificar (servidor, tras el ataque)

```bash
ip route get <IP_SERVIDOR>
```

| Modo | Resultado |
|------|-----------|
| Vulnerable | Aparece `mtu 576` |
| Mitigado | MTU normal, ICMP forjado ignorado |
