ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y mariadb-server procps && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Entrypoint scripti (az önce oluşturduğumuz dosya)
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
