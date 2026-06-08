# Punto 03 — TCP Session Hijacking (Challenge ACK Side-Channel)

Demostración del canal colateral CVE-2016-5696 mediante SYN fuera de ventana.

## Topología

| Host     | IP        | Rol                              |
|----------|-----------|----------------------------------|
| Servidor | 10.9.0.5  | nc -lk :9999, sesión TCP         |
| Cliente  | 10.9.0.6  | Conexión netcat al servidor      |
| Atacante | 10.9.0.7  | challenge_ack_probe.py           |

## Ejecución

```bash
cd vulnerable && chmod +x demo.sh && ./demo.sh
cd ../mitigado && chmod +x demo.sh && ./demo.sh
```

## Mitigación

`sysctl net.ipv4.tcp_challenge_ack_limit=2147483647` en el servidor elimina la variación en Challenge ACKs.
