FROM alpine:3.20
RUN apk add --no-cache nginx openssl gettext

# conf klasörleri
RUN rm -f /etc/nginx/http.d/default.conf || true
RUN mkdir -p /etc/nginx/http.d /etc/nginx/certs

# Ana nginx.conf (http.d/*.conf include eder)
COPY nginx.conf /etc/nginx/nginx.conf

# Site config (template)
COPY conf/site.conf.template /etc/nginx/http.d/site.conf.template

# Entrypoint'i doğru YERDEN kopyala (Docker build context = requirements/nginx)
COPY tools/script.sh /usr/local/bin/entrypoint.sh

# CRLF -> LF ve çalıştırılabilir yap
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
 && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443
CMD ["/usr/local/bin/entrypoint.sh"]
