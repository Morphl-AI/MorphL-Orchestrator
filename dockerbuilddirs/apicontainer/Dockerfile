FROM nginx:alpine

ADD nginx.conf /etc/nginx/

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash -Gwww-data www-data \
    && rm /etc/nginx/conf.d/default.conf
CMD ["nginx"]

EXPOSE 80 443