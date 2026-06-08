# Punto 09 — Low-Rate Denial of Service (LDoS)

Ataque Shrew con ráfagas UDP periódicas (T=1.0s, L=0.15s) sincronizadas con RTO mínimo TCP.

## Topología

| Rol | IP |
|-----|-----|
| Atacante | 10.9.0.101 |
| Cliente (descarga) | 10.9.0.102 |
| Servidor HTTP | 10.9.0.103 |

## Mitigación

`hashlimit` en el servidor limita ráfagas UDP del atacante.
