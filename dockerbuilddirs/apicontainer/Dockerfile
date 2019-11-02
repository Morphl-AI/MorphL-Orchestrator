FROM nginx:alpine

ADD nginx.conf /etc/nginx/
COPY api.conf /etc/nginx/sites-available/

ARG AUTH_KUBERNETES_CLUSTER_IP_ADDRESS

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash -Gwww-data www-data \
    && rm /etc/nginx/conf.d/default.conf \
    && echo -e "upstream kubernetes-upstream-auth { server ${AUTH_KUBERNETES_CLUSTER_IP_ADDRESS}; } \n" > /etc/nginx/conf.d/upstream.conf

CMD ["nginx"]

EXPOSE 80 443