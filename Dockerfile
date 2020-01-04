FROM ubuntu:disco

ARG DNS_SERVER=127.0.0.11
ARG FPM_HOST=php-fpm
ARG FPM_PORT=9000
ARG APP_HOSTNAME=localhost

RUN set -x \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y nginx gettext libluajit-5.1-2 libluajit-5.1-common libnginx-mod-http-lua libnginx-mod-http-ndk \
  && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list \
  && apt-get autoremove -y \
  && rm -rf /etc/ssl/nginx

ADD nginx.template /etc/nginx/nginx.template
RUN envsubst '${DNS_SERVER}' < /etc/nginx/nginx.template > /etc/nginx/nginx.conf

ADD site.template /etc/nginx/site.template
RUN envsubst '${APP_HOSTNAME},${FPM_HOST},${FPM_PORT}' < /etc/nginx/site.template > /etc/nginx/sites-enabled/default

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

STOPSIGNAL SIGTERM

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
