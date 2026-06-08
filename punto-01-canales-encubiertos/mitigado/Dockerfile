FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends iproute2 iputils-ping tcpdump \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir scapy
WORKDIR /lab
COPY scripts/ /lab/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
