# requirements/mariadb/Dockerfile
FROM mariadb:11

# (İsteğe bağlı) kendi MariaDB konfiginiz
# Not: Dosya adını açıkça veriyoruz
COPY ./tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# (İsteğe bağlı) ilk kurulum SQL dosyalarınız varsa:
# COPY ./tools/initdb/*.sql /docker-entrypoint-initdb.d/

# ÖNEMLİ: CMD/ENTRYPOINT EKLEME!
# Resmi imaj zaten doğru entrypoint (docker-entrypoint.sh) ve CMD (mysqld) ile geliyor.
