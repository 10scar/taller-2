#!/bin/sh
sleep 3
MY_IP=$(ip -4 -o addr show eth0 | awk '{print $4}' | cut -d/ -f1)
if [ "$MY_IP" = "10.9.0.101" ]; then
  ip route replace 10.9.0.102/32 via 10.9.0.1 dev eth0
elif [ "$MY_IP" = "10.9.0.102" ]; then
  ip route replace 10.9.0.101/32 via 10.9.0.1 dev eth0
fi
exec tail -f /dev/null
