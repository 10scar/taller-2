# Punto 13 — Guía del atacante (Slowloris)

Ataque **Low-and-Slow** contra el servidor HTTP del laboratorio. Solo necesitas estar en la **misma red** que quien levantó el lab y conocer su **IP LAN** (ej. `192.168.1.50`).

**Objetivo:** saturar el servidor abriendo conexiones HTTP que nunca envían la petición completa, de modo que un cliente legítimo no pueda conectar.

---

## Datos que te debe dar el operador del lab

| Dato | Ejemplo |
|------|---------|
| IP del host en la red | `192.168.1.50` |
| Puerto del servidor | `8080` |
| Modo actual | vulnerable o mitigado |

URL del objetivo: `http://192.168.1.50:8080/`

---

## Paso 1 — Comprobar conectividad

En tu PC (Linux, macOS o WSL):

```bash
ping -c 2 192.168.1.50
curl --max-time 5 http://192.168.1.50:8080/
```

Si `curl` devuelve `OK`, el servidor está listo **antes** del ataque.

---

## Paso 2 — Obtener el script de ataque

Copia `slow_attack.py` del repositorio del taller:

```
punto-13-low-and-slow/vulnerable/scripts/slow_attack.py
```

O pídeselo al operador. Requisitos: **Python 3** (sin librerías extra).

---

## Paso 3 — Lanzar el ataque Slowloris

Abre una terminal y ejecuta (deja la terminal abierta mientras dura el ataque):

```bash
python3 slow_attack.py 192.168.1.50 8 8080
```

| Argumento | Significado |
|-----------|-------------|
| `192.168.1.50` | IP LAN del host (sustituye por la real) |
| `8` | Número de conexiones lentas simultáneas |
| `8080` | Puerto expuesto en el host |

Salida esperada:

```
[*] Abriendo 8 conexiones lentas hacia 192.168.1.50:8080...
[+] 8 sockets abiertos
[*] Ciclo 1/4: manteniendo 8 sockets...
...
```

El script dura unos **12 segundos** (4 ciclos × 3 s). Para mantener el ataque más tiempo, vuelve a ejecutar el comando o pide al operador una versión con más ciclos.

---

## Paso 4 — Verificar que el servidor cae

**Mientras el ataque sigue activo**, abre **otra terminal** y prueba como cliente legítimo:

```bash
curl --max-time 5 http://192.168.1.50:8080/
```

| Resultado | Interpretación |
|-----------|----------------|
| Timeout o `Connection refused` / sin respuesta | **Ataque exitoso** — pool del servidor agotado |
| `OK` rápido | Servidor aún responde (pocos sockets o modo mitigado) |

---

## Paso 5 — Probar contra la versión mitigada

El operador levanta `mitigado/` en lugar de `vulnerable/`. Repite los pasos 1–4 con la misma IP y puerto.

En modo **mitigado**, `curl` debería seguir devolviendo `OK` aunque lances el ataque, gracias a `connlimit` en el servidor.

---

## Resumen de comandos

```bash
# 1. Comprobar
curl http://<IP_HOST>:8080/

# 2. Atacar (terminal 1)
python3 slow_attack.py <IP_HOST> 8 8080

# 3. Comprobar daño (terminal 2, durante el ataque)
curl --max-time 5 http://<IP_HOST>:8080/
```

---

## Solución de problemas

| Problema | Qué hacer |
|----------|-----------|
| `Connection timed out` al hacer ping | Misma red WiFi/LAN; revisar firewall del host |
| `curl` al puerto 8080 falla siempre | El operador debe tener `docker compose up` y el servidor en marcha |
| El ataque no tumba el servidor | Sube sockets: `python3 slow_attack.py <IP> 12 8080` |
| `python3: command not found` | Instala Python 3 o usa `python` |

---

## Aviso

Usa este laboratorio **solo en la red del taller** y con autorización. No ejecutes Slowloris contra sistemas reales sin permiso explícito.
