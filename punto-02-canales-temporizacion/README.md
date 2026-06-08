# Punto 02 — Canales por Temporización

Demostración de canal encubierto basado en intervalos entre paquetes (IPD).

## Topología

| Host    | IP         | Rol                          |
|---------|------------|------------------------------|
| Emisor  | 10.9.0.101 | Envía ICMP con retardo corto/largo |
| Receptor| 10.9.0.102 | Mide IPD y decodifica bits   |
| Gateway | 10.9.0.1   | Solo en mitigado (jammer netem)|

## Ejecución

```bash
cd vulnerable && chmod +x demo.sh && ./demo.sh
cd ../mitigado && chmod +x demo.sh && ./demo.sh
```

## Manual

```bash
docker compose up -d --build
docker compose exec -d receptor python3 /lab/timing_recv.py 10.9.0.101
docker compose exec emisor python3 /lab/timing_send.py 10.9.0.102 1010
```

- **Vulnerable**: decodifica `1010` correctamente.
- **Mitigado**: gateway aplica `tc netem delay 100ms 50ms`; la decodificación falla.
