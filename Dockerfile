FROM phpearth/php:7.4-nginx AS base
RUN apk add --update --no-cache curl jq php7.4-pdo_mysql
RUN mkdir -p /home/domcord
WORKDIR /home/domcord

FROM base AS environment
ARG DOMCORD_LICENSE_KEY
ENV DOMCORD_LICENSE_KEY $DOMCORD_LICENSE_KEY
RUN if [ -z "$DOMCORD_LICENSE_KEY" ]; then \
    echo 'Environment variable DOMCORD_LICENSE_KEY must be specified. Exiting.'; \
    exit 1; \
    fi
RUN if [ $(\
    curl "https://domcord.dommioss.fr/api/licence_verify.php?key=$DOMCORD_LICENSE_KEY" \
    | jq -r '.complete' \
    ) = "false" ]; then \
    echo 'The Domcord License Key is invalid'; \
    exit 1; \
    fi

FROM environment AS nginx-server
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

FROM nginx-server AS domcord-blank
ADD "https://domcord.dommioss.fr/api/last_update.json" last-update.json
RUN curl $(cat last-update.json | jq -r '.[1].dlurl') -o domcord.zip
RUN mkdir php
RUN unzip domcord.zip -d php

FROM domcord-blank AS domcord-config
RUN echo 'state: "2"' > php/installation/state.yml