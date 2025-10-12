ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}


RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

# self-signed sertifika (gerekirse gerçek sertifika ile değiştir)
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/selfsigned.key \
    -out /etc/nginx/ssl/selfsigned.crt \
    -subj "/CN=localhost"

COPY conf/default.conf /etc/nginx/conf.d/default.conf

# docroot wordpress volume ile paylaşılacak
WORKDIR /var/www/html
EXPOSE 443

# PID1 olarak nginx master
CMD ["nginx","-g","daemon off;"]
