# Punto 12 — Downgrade Attacks TLS

Servidor web con TLS 1.0 habilitado (vulnerable) vs TLS 1.2+ únicamente (mitigado).

## Topología

| Rol | IP |
|-----|-----|
| Cliente | 10.9.0.102 |
| Servidor | 10.9.0.103 |

## Demo

`openssl s_client -connect 10.9.0.103:443 -tls1`
