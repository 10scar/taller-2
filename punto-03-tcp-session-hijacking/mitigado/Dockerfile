FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iputils-ping tcpdump procps netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir scapy
WORKDIR /lab
COPY scripts/ /lab/
COPY entrypoint-server.sh /entrypoint-server.sh
RUN chmod +x /entrypoint-server.sh
CMD ["sleep", "infinity"]
