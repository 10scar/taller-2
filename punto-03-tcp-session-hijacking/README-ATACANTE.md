# Punto 03 — Guía del atacante remoto (sin SSH)

Canal colateral **CVE-2016-5696** desde tu PC: mantienes una sesión TCP al servidor expuesto y lanzas el probe Scapy hacia `10.9.0.5`.

---

## Datos del operador

| Dato | Ejemplo |
|------|---------|
| IP LAN del host | `10.203.2.231` |
| Puerto servidor | `9999` |

El operador debe tener `docker compose up` y `sudo ../../lib/lan-expose.sh` ejecutados.

---

## Requisitos en tu PC

```bash
pip install scapy
```

---

## Paso 1 — Ruta y conectividad

```bash
sudo ip route add 10.9.0.0/24 via <IP_HOST>
ping -c 2 <IP_HOST>
ping -c 2 10.9.0.5
echo hola | nc -w 3 <IP_HOST> 9999
```

---

## Paso 2 — Sesión TCP activa (terminal 1)

Deja esta terminal **abierta**:

```bash
(echo sesion-activa; sleep 120) | nc <IP_HOST> 9999
```

O interactivo:

```bash
nc <IP_HOST> 9999
```

---

## Paso 3 — Probe del atacante (terminal 2)

```bash
cd punto-03-tcp-session-hijacking/vulnerable/scripts
sudo python3 challenge_ack_probe.py 10.9.0.5 10.9.0.6
```

Salida vulnerable:

```
[+] CANAL COLATERAL ACTIVO: respuestas diferenciadas (vulnerable)
```

Salida mitigada:

```
[+] Respuestas uniformes — side-channel mitigado
```

---

## Al terminar (tu PC)

```bash
sudo ip route del 10.9.0.0/24 via <IP_HOST>
```

---

## Resumen

| Terminal | Comando |
|----------|---------|
| 1 | `(echo sesion-activa; sleep 120) \| nc <IP_HOST> 9999` |
| 2 | `sudo python3 challenge_ack_probe.py 10.9.0.5 10.9.0.6` |

---

## Solución de problemas

| Problema | Solución |
|----------|----------|
| `nc` al 9999 falla | Operador: lab + `firewall-cmd --add-port=9999/tcp` |
| `ping 10.9.0.5` falla | Operador: `sudo ../../lib/lan-expose.sh` |
| Respuestas uniformes en vulnerable | Mantén la sesión del paso 2 antes del probe |

---

## Aviso

Solo en la red del taller.
