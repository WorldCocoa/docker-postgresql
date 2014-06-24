##################################### VARIABLES #################################


#Get the current directory of this Makefile as it may be included in other Makefiles
#http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
PSQL_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PSQL_DIR := $(abspath $(patsubst %/,%,$(dir $(PSQL_PATH))))

#Get the path to the top most Makefile, or wherever this command was invoked from
TOP_PATH := $(shell pwd)

#These could already be set in the env or when this Makefile 
#is included in the devtools/Makefile
PSQL_TAG_NAME ?= xela7/cocoamap-postgresql
PSQL_SERVER_CONTAINER_NAME ?= cocoamap_postgresql_server
PSQL_PORT ?= 5432
PSQL_DUMP_FILE ?= ${TOP_PATH}/20140624cocoamap.sql.gz
POSTGRESQL_USER ?= cocoamap
POSTGRESQL_PASS ?= cocoamap
POSTGRESQL_DB   ?= cocoamap


#PSQL Server command line options
PSQL_SERVER_OPTS = --name=${PSQL_SERVER_CONTAINER_NAME} 
PSQL_SERVER_OPTS += -p ${PSQL_PORT}:5432 
PSQL_SERVER_OPTS += -v /opt/data/postgresql:/var/lib/postgresql 

#PSQL User and DB command line options
PSQL_USER_OPTS = -e POSTGRESQL_USER=${POSTGRESQL_USER} 
PSQL_USER_OPTS += -e POSTGRESQL_PASS=${POSTGRESQL_PASS} 
PSQL_USER_OPTS += -e POSTGRESQL_DB=${POSTGRESQL_DB} 


#For creating / dumping databases - requires the psql client 
PSQL = PGPASSWORD=$(POSTGRESQL_PASS) psql -U $(POSTGRESQL_USER) -h 127.0.0.1


##################################### RUN SERVER AND OTHER RUN FUNCTIONS #################################


#Runs the PostgresSQL Server
psql-run: psql-clean
	docker run -d ${PSQL_SERVER_OPTS} ${PSQL_USER_OPTS} ${PSQL_TAG_NAME} /home/docker/run.server.sh


#Stops the PostgresSQL Server
psql-stop:
	-@docker stop ${PSQL_SERVER_CONTAINER_NAME} 2>/dev/null || true
	

psql-clean: psql-stop
	-@docker rm ${PSQL_SERVER_CONTAINER_NAME} 2>/dev/null || true

#Hop into the shell and connect to the local database
psql-shell:
	$(PSQL)


#Utility to hop into the postgres admin shell (selects the postgres database)
psql-admin-shell:
	$(PSQL) postgres



################################### DUMP / IMPORT DATA ######################################
#You must add the PSQL_DUMP_FILE yourself and it should be a gzipped version of the GlobAllomeTree db
#This uses env vars to avoid the password prompt
#http://www.postgresql.org/docs/current/static/libpq-envars.html
#To use a different dump file, override the PSQL_DUMP_FILE variable when calling Make
#ex) make psql-import-db PSQL_DUMP_FILE=../globallometree.import.sql.2.gz
#Note that $(PSQL) is defined at the beginning of the Makefile but evaluated when used below
psql-import-db: 
	gunzip -c $(PSQL_DUMP_FILE) | $(PSQL)


psql-drop-db:
	echo "DROP DATABASE  IF EXISTS  ${POSTGRESQL_DB};" | $(PSQL) postgres 


psql-create-db:
	echo "CREATE DATABASE ${POSTGRESQL_DB} OWNER ${POSTGRESQL_USER} ENCODING 'UTF8' TEMPLATE template0; " | $(PSQL) postgres


psql-reset-db: psql-drop-db psql-create-db


psql-dump-db:
	PGPASSWORD=$(POSTGRESQL_PASS) pg_dump -U $(POSTGRESQL_USER) -h $(shell ${PSQL_DIR}/ip_for.sh ${PSQL_SERVER_CONTAINER_NAME}) $(POSTGRESQL_DB) | gzip > ../$(POSTGRESQL_DB).dump.`date +'%Y_%m_%d'`.sql.gz
	@echo "database exported to ${POSTGRESQL_DB}.`date +'%Y_%m_%d'`.sql.gz"


##################################### DOCKER BUILD AND SERVER INIT UTILS #################################


#All names should be prefixed with psql
psql-build:
	cd ${PSQL_DIR} && docker build -t ${PSQL_TAG_NAME} .


psql-init: psql-stop psql-make-data-dir psql-run psql-sleep10 psql-create-db  


psql-print-env:
	#Print out the environment a container linking to the server would see
	#Requireds the postgresql server to be running
	docker run --rm --link ${PSQL_SERVER_CONTAINER_NAME}:PSQL ${PSQL_USER_OPTS} ${PSQL_TAG_NAME} env


#Force postgres to reinitialize everything which happens in the docker postgresql run.sh script if db is not initialized
#TODO: Add a confirm here
psql-delete-data-dir:
	sudo rm -rf /opt/data/postgresql 


psql-make-data-dir:
	sudo mkdir -p /opt/data/postgresql

#This does a full reset of postgres from a dump file
#To use a different dump file, override the PSQL_DUMP_FILE variable when calling Make
#ex) make psql-reset-all PSQL_DUMP_FILE=../globallometree.import.sql.2.gz
psql-reset-all: psql-clean psql-delete-data-dir psql-init 


psql-sleep10:
	sleep 10


################################### Add in PostgreSQL client to ubuntu #####################

psql-add-postgres-ubuntu-repo:
	echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /tmp/pgdg.list
	sudo cp /tmp/pgdg.list /etc/apt/sources.list.d/
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	sudo apt-get update

psql-add-postgres-ubuntu-client: psql-add-postgres-ubuntu-repo 
	sudo apt-get install -y postgresql-client-9.3 git 


#################################### !!! Experimental Piping of data (does not work as expected) !!! ##########################
# #Uses the images postgresql client to send sql to the server by piping data to it... in theory
# psql-run-sql:
# 	docker run --rm --link ${PSQL_SERVER_CONTAINER_NAME}:PSQL ${PSQL_USER_OPTS} -e SQL="${SQL}" ${PSQL_TAG_NAME} /home/docker/run.sql.sh


# #Uses the images postgresql client to send sql to the server
# psql-run-test:
# 	$(PSQL_RUN_SQL) <<< "Hello"
	
# psql-run-test-2:
# 	$(PSQL_RUN_SQL) < ${PSQL_DIR}/test.sql 

# psql-run-test-3:
# 	$(PSQL_RUN_SQL) <<< $(shell cat ${PSQL_DIR}/test.sql) 

# psql-check-file:
# 	cat ${PSQL_DIR}/test.sql


#--rm to remove the container as soon as the command finishes
#--interactive since that seems to be the only way to see the response back from the command
#--link is to link to the container running the server
#--attach=stdin could be an alternative to pipe into the docker container, but unsure how to access logs
#PSQL_RUN_SQL = docker run --rm --interactive=true --link ${PSQL_SERVER_CONTAINER_NAME}:PSQL ${PSQL_USER_OPTS} ${PSQL_TAG_NAME} /home/docker/run.sql.sh



