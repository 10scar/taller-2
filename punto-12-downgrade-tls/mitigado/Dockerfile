FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl curl \
    && rm -rf /var/lib/apt/lists/*
COPY nginx.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/ssl/private/nginx-selfsigned.key \
       -out /etc/ssl/certs/nginx-selfsigned.crt \
       -subj "/CN=lab.local"
ENTRYPOINT ["/entrypoint.sh"]
