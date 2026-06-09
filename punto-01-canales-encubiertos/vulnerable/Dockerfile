FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iputils-ping tcpdump openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash lab \
    && echo 'lab:lab' | chpasswd \
    && mkdir -p /run/sshd \
    && printf 'PasswordAuthentication yes\nPermitRootLogin no\n' > /etc/ssh/sshd_config.d/lab.conf
RUN pip install --no-cache-dir scapy
WORKDIR /lab
COPY scripts/ /lab/
CMD ["/bin/sh", "-c", "/usr/sbin/sshd && exec sleep infinity"]
