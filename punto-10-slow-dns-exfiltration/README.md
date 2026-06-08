# Punto 10 — Exfiltración Lenta por DNS

Codifica datos en subdominios hex y los resuelve vía el resolvedor del campus hacia el DNS del atacante.

## Topología

| Rol | IP |
|-----|-----|
| Host comprometido | 10.9.0.102 |
| Resolvedor | 10.9.0.53 |
| DNS atacante | 10.9.0.101 |

## Mitigación

El resolvedor mitigado rechaza consultas DNS excesivamente largas (filtro complementario a dnsmasq).
