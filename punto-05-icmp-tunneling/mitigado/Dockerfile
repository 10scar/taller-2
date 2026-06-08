FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iputils-ping tcpdump procps iptables \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir scapy
WORKDIR /lab
COPY scripts/ /lab/
COPY entrypoint-receptor.sh /entrypoint-receptor.sh
RUN chmod +x /entrypoint-receptor.sh
CMD ["sleep", "infinity"]
