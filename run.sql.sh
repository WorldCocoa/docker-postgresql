#!/bin/bash


#EXPERIMENTAL! doesn't work yet
#Trying to work with using the container's psql client but having issues with pipes, here docs, etc...

#Read from stdin
#http://stackoverflow.com/questions/18761209/how-to-make-a-bash-script-to-read-from-stdin

read -r SQL;
echo $SQL;

#echo "${SQL}" | PGPASSWORD=${POSTGRESQL_PASS} psql -h ${PSQL_PORT_5432_TCP_ADDR} -p ${PSQL_PORT_5432_TCP_PORT} -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DB} 
