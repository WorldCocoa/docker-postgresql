POSTGRESQL_USER=${POSTGRESQL_USER:-"docker"}
POSTGRESQL_PASS=${POSTGRESQL_PASS:-"docker"}
POSTGRESQL_DB=${POSTGRESQL_DB:-"docker"}

POSTGRESQL_BIN=/usr/lib/postgresql/9.3/bin/postgres
POSTGRESQL_CONFIG_FILE=/etc/postgresql/9.3/main/postgresql.conf
POSTGRESQL_DATA=/var/lib/postgresql/9.3/main