#!/bin/bash
set -e

#Include the run config vars
. run.config.sh

sudo -u postgres $POSTGRESQL_BIN --single --config-file=$POSTGRESQL_CONFIG_FILE <<< ${SQL_STATEMENT}