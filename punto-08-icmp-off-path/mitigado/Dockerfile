FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iptables tcpdump net-tools iputils-ping dnsutils curl wget openssl \
    procps arping netcat-openbsd iperf3 dnsmasq \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir scapy
WORKDIR /lab
COPY scripts/ /lab/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
