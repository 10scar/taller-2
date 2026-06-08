#!/usr/bin/env python3
"""Scaffold all 13 lab directories."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

NETWORK = """
networks:
  labnet:
    driver: bridge
    ipam:
      config:
        - subnet: 10.9.0.0/24
"""

DOCKERFILE = """FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \\
    iproute2 iptables tcpdump net-tools iputils-ping dnsutils curl wget openssl \\
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir scapy pillow
WORKDIR /lab
COPY scripts/ /lab/
"""

def write(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + "\n", encoding="utf-8")

def compose(services: str, project_suffix: str = "") -> str:
    return f"services:\n{services}\n{NETWORK}"

print("Scaffold helper - run individual lab creation")
