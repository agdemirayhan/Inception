# requirements/nginx/Dockerfile
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGQUIT
EXPOSE 80 443
CMD ["nginx","-g","daemon off;"]