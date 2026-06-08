# Punto 05 — Tunelización ICMP

Encapsulación de datos en payload ICMP Echo Request/Reply.

## Topología

| Host     | IP         | Rol                    |
|----------|------------|------------------------|
| Emisor   | 10.9.0.101 | send_icmp.py           |
| Receptor | 10.9.0.102 | recv_icmp.py (sniff)   |

## Ejecución

```bash
cd vulnerable && chmod +x demo.sh && ./demo.sh
cd ../mitigado && chmod +x demo.sh && ./demo.sh
```

## Mitigación

`iptables -A INPUT -p icmp --icmp-type echo-request -m length --length 85:65535 -j DROP`

- **Vulnerable**: mensaje recibido en receptor.
- **Mitigado**: paquetes largos bloqueados.
