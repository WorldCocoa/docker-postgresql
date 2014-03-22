#!/bin/bash
set -e

#Include the run config vars
. run.config.sh

if [ ! -d $POSTGRESQL_DATA ]; then
    mkdir -p $POSTGRESQL_DATA
    chown -R postgres:postgres $POSTGRESQL_DATA
    sudo -u postgres /usr/lib/postgresql/9.3/bin/initdb -D $POSTGRESQL_DATA
    ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem $POSTGRESQL_DATA/server.crt
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key $POSTGRESQL_DATA/server.key
fi

exec sudo -u postgres $POSTGRESQL_BIN --config-file=$POSTGRESQL_CONFIG_FILE