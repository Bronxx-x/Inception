FROM debian:bullseye

RUN apt update -y && apt install -y mariadb-server && rm -rf /var/lib/apt/lists/*

# Copy custom config
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
