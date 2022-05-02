FROM phpearth/php:7.4-nginx AS base
RUN apk add --update --no-cache curl jq php7.4-pdo_mysql
RUN mkdir -p /home/domcord
WORKDIR /home/domcord

FROM base AS domcord
ADD "https://domcord.dommioss.fr/api/last_update.json" last-update.json
RUN curl $(cat last-update.json | jq -r '.[1].dlurl') -o domcord.zip
RUN mkdir php
RUN unzip domcord.zip -d php

FROM domcord AS nginx-server
COPY ./nginx.conf /etc/nginx/conf.d/default.conf