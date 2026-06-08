FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iptables tcpdump procps dnsmasq dnsutils \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir scapy
WORKDIR /lab
COPY scripts/ /lab/
COPY dnsmasq/ /etc/dnsmasq/
COPY entrypoint-auth.sh entrypoint-resolver.sh / 
RUN chmod +x /entrypoint-auth.sh /entrypoint-resolver.sh
CMD ["sleep", "infinity"]
