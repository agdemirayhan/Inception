FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql \
 && chmod 755 /run/mysqld

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]