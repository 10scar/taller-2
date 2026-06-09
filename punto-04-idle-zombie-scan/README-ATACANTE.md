# Punto 04 — Guía del atacante remoto (sin SSH)

Idle / Zombie scan desde **tu PC**: mides el delta del IP ID del zombie `10.9.0.150` para inferir si el puerto 80 está abierto en `10.9.0.200`.

---

## Datos del operador

| Dato | Ejemplo |
|------|---------|
| IP LAN del host | `10.203.2.231` |
| Puerto objetivo (prueba directa) | `8080` |

El operador debe tener `docker compose up` y `sudo ../../lib/lan-expose.sh` ejecutados.

---

## Requisitos en tu PC

```bash
pip install scapy
```

---

## Paso 1 — Ruta y comprobaciones

```bash
sudo ip route add 10.9.0.0/24 via <IP_HOST>
ping -c 2 <IP_HOST>
ping -c 2 10.9.0.150
ping -c 2 10.9.0.200
echo test | nc -w 3 <IP_HOST> 8080
```

`nc` al 8080 confirma que el objetivo está vivo (conexión directa). El idle scan demuestra que puedes inferir el puerto **sin** usar tu IP como origen del SYN hacia el objetivo.

---

## Paso 2 — Ejecutar idle scan

```bash
cd punto-04-idle-zombie-scan/vulnerable/scripts
sudo python3 idle_scan.py 10.9.0.150 10.9.0.200 80
```

Salida vulnerable:

```
[+] Delta IP ID: 1
[+] Puerto 80/tcp ABIERTO en 10.9.0.200
```

Salida mitigada:

```
[+] Delta IP ID: 0
[-] Puerto 80/tcp cerrado/filtrado (delta=0)
```

---

## Al terminar (tu PC)

```bash
sudo ip route del 10.9.0.0/24 via <IP_HOST>
```

---

## Resumen

```bash
sudo ip route add 10.9.0.0/24 via <IP_HOST>
nc <IP_HOST> 8080
cd punto-04-idle-zombie-scan/vulnerable/scripts
sudo python3 idle_scan.py 10.9.0.150 10.9.0.200 80
```

---

## Solución de problemas

| Problema | Solución |
|----------|----------|
| `ping 10.9.0.150` falla | Operador: `sudo ../../lib/lan-expose.sh` |
| Zombie sin respuesta | Espera 3 s tras `compose up` del operador |
| Delta 0 en vulnerable | Reintenta; comprueba que `zombie` esté Up |

---

## Aviso

Solo en la red del taller. IP spoofing en redes reales requiere autorización.
