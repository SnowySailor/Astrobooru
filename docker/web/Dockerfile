FROM nginx:1.17.10
ENV APP_DIR /srv/philomena

COPY docker/web/nginx.conf /tmp/docker.nginx
COPY docker/web/ssl_data/fullchain.pem /etc/letsencrypt/live/astrobooru.com/fullchain.pem
COPY docker/web/ssl_data/privkey.pem /etc/letsencrypt/live/astrobooru.com/privkey.pem
COPY docker/web/ssl_data/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
COPY docker/web/ssl_data/ssl-dhparams.pem  /etc/letsencrypt/ssl-dhparams.pem

RUN envsubst '$APP_DIR' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
