FROM nginx:1.18.0
ENV APP_DIR /srv/philomena

RUN apt-get update && apt-get install -y certbot python-certbot-nginx
COPY docker/web/nginx.conf /tmp/docker.nginx
COPY docker/web/ssl_data/letsencrypt /etc/letsencrypt/

RUN envsubst '$APP_DIR' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
