# Punto 06 — DNS Cache Poisoning

Envenenamiento de caché DNS mediante respuestas UDP forjadas (estilo Kaminsky).

## Topología

| Host      | IP          | Rol                          |
|-----------|-------------|------------------------------|
| Resolvedor| 10.9.0.53   | dnsmasq recursivo            |
| Auth DNS  | 10.9.0.120  | dnsmasq autoritativo ejemplo.com |
| Atacante  | 10.9.0.153  | dns_poison.py (Scapy)        |

## Ejecución

```bash
cd vulnerable && chmod +x demo.sh && ./demo.sh
cd ../mitigado && chmod +x demo.sh && ./demo.sh
```

## Mitigación

iptables en el resolvedor filtra respuestas DNS forjadas (string match sobre payload envenenado).

- **Vulnerable**: `dig @10.9.0.53 test.ejemplo.com` puede devolver `1.1.1.1`.
- **Mitigado**: respuesta legítima `10.10.10.10` se mantiene.
