# 02 — Canal por temporización (LAN)

## Vulnerable

```bash
./servidor.sh
sudo ./atacante.sh <IP_SERVIDOR>    # en PC atacante
```

Esperado en servidor: `DECODIFICACIÓN EXITOSA: 1010`

## Mitigado

Jitter `tc netem delay 100ms 50ms` en la interfaz LAN.

```bash
./servidor-mitigado.sh
sudo ./atacante.sh <IP_SERVIDOR>
```

Esperado: decodificación incorrecta o secuencia distinta a `1010`.
