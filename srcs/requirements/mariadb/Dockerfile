ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y mariadb-server procps && rm -rf /var/lib/apt/lists/*

# Konfig
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# İlk kurulum scriptleri
COPY tools/init.sql /docker-entrypoint-initdb.d/init.sql

# Sağlıklı PID1: mysqld doğrudan process olarak çalışsın (tail -f/sleep yok!)
EXPOSE 3306
VOLUME ["/var/lib/mysql"]

# healthcheck için mysqladmin kullanacağız (compose içinde)
ENTRYPOINT ["bash","-lc","exec mysqld --user=mysql --bind-address=0.0.0.0"]
