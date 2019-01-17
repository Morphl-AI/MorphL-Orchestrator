FROM nginx:alpine

ADD nginx.conf /etc/nginx/
COPY api.conf /etc/nginx/sites-available/

ARG KUBERNETES_CLUSTER_IP_ADDRESS

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash www-data \
    && rm /etc/nginx/conf.d/default.conf \
    && echo "upstream kubernetes-upstream { server ${KUBERNETES_CLUSTER_IP_ADDRESS}; }" > /etc/nginx/conf.d/upstream.conf

CMD ["nginx"]

EXPOSE 80 443