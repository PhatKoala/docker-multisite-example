#!/bin/bash

SITE="$1"

export $(grep -v '#.*' .env | xargs)
export $(grep -v '#.*' sites/$SITE/.env | xargs)

docker exec mysql bash -c "mysql -uroot -p$MYSQL_ROOT_PASSWORD -e \"CREATE DATABASE $MYSQL_NAME\""
# @todo Replace % with container name?
docker exec mysql bash -c "mysql -uroot -p$MYSQL_ROOT_PASSWORD -e \"CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'\""
docker exec mysql bash -c "mysql -uroot -p$MYSQL_ROOT_PASSWORD -e \"GRANT ALL PRIVILEGES ON $MYSQL_NAME.* TO '$MYSQL_USER'@'%';\""

openssl req -x509 -out nginx/certs/$DOMAIN.crt -keyout nginx/certs/$DOMAIN.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=$DOMAIN' -extensions EXT -config <( \
   printf "[dn]\nCN=$DOMAIN\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$DOMAIN\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")