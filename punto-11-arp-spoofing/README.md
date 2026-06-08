# Punto 11 — ARP Spoofing Silencioso

Envenenamiento ARP lento: el atacante anuncia que la IP del gateway (10.9.0.1) corresponde a su MAC.

## Topología

| Rol | IP | MAC (referencia PDF) |
|-----|-----|-----|
| Atacante | 10.9.0.10 | aa:bb:cc:dd:ee:01 |
| Víctima | 10.9.0.20 | 11:22:33:44:55:01 |
| Gateway | 10.9.0.1 | 00:11:22:33:44:01 |

> Docker asigna MACs reales en tiempo de ejecución; el demo las detecta automáticamente.

## Mitigación

Entrada ARP estática en la víctima: `arp -s 10.9.0.1 00:11:22:33:44:01`
