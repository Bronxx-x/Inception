FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

# SSL cert generation
RUN mkdir -p /etc/nginx/ssl

# Copy Nginx config
COPY conf/default.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

EXPOSE 80 443

CMD ["/bin/bash", "/usr/local/bin/start-nginx.sh"]
