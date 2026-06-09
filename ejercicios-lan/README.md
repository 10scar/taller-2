# Ejercicios LAN — Sin Docker

Laboratorios **02, 03, 04, 05, 07 y 08** ejecutados directamente en Linux, accesibles por **IP LAN** sin SSH, sin rutas `10.9.0.0/24` ni Docker.

## Arquitectura

| Máquina | Rol |
|---------|-----|
| **Servidor** | Tu PC Fedora — corre los servicios víctima/receptor |
| **Atacante** | Otro PC en la misma red — solo necesita la IP del servidor |

## Requisitos

**Servidor y atacante:**

```bash
pip install -r requirements.txt
# Scripts Scapy: sudo python3 ...
```

**Servidor además:** `nc` (netcat), `iproute2`, permisos `sudo` para sniffing/iptables/sysctl.

## Inicio rápido

```bash
chmod +x ejercicios-lan/**/*.sh ejercicios-lan/lib/*.sh
```

1. En el **servidor**: `cd ejercicios-lan/0X-...` → `./servidor.sh` o `./servidor-mitigado.sh`
2. Comparte la **IP LAN** que imprime el script
3. En el **atacante**: `./atacante.sh <IP_SERVIDOR>` (mismo comando en vulnerable y mitigado)

## Laboratorios

| # | Carpeta | Puerto(s) | Atacante necesita |
|---|---------|-----------|-------------------|
| 02 | [02-timing](02-timing/) | ICMP | `sudo` + Scapy |
| 03 | [03-challenge-ack](03-challenge-ack/) | TCP 9999 | `sudo` + Scapy + `nc` |
| 04 | [04-idle-scan](04-idle-scan/) | TCP 8080 + IP alias zombie | `sudo` + Scapy |
| 05 | [05-icmp-tunnel](05-icmp-tunnel/) | ICMP | `sudo` + Scapy |
| 07 | [07-fragmentacion](07-fragmentacion/) | UDP 9999 | `sudo` + Scapy |
| 08 | [08-icmp-off-path](08-icmp-off-path/) | TCP 8080 | `sudo` + Scapy |

Cada carpeta incluye `servidor-mitigado.sh` con la contramedida del taller (sysctl, iptables o `tc netem`). Ctrl+C restaura reglas/sysctl donde aplica.

## Firewall (servidor Fedora)

Los scripts `servidor.sh` abren puertos con `firewall-cmd` si hace falta. ICMP/UDP pueden requerir que la red permita ese tráfico.

## Detener servicios

Cada `servidor.sh` deja procesos en background. Para parar:

```bash
./stop.sh
```

(o `Ctrl+C` si corre en primer plano)
