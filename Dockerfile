FROM xela7/cocoamap-base

MAINTAINER Alex Tokar "alext@bitbamboo.com"

ENV LC_ALL en_US.UTF-8 
ENV	DEBIAN_FRONTEND noninteractive

RUN wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
	postgresql-9.3 \
	postgresql-contrib-9.3 \
	postgresql-9.3-postgis \
	libpq-dev \
	ssl-cert

#Update the servers default ssl certs (not sure if this is really required)
RUN make-ssl-cert generate-default-snakeoil --force-overwrite
RUN cp /etc/ssl/certs/ssl-cert-snakeoil.pem  /home/docker/ssl-cert-snakeoil.pem \ 
 && cp /etc/ssl/private/ssl-cert-snakeoil.key /home/docker/ssl-cert-snakeoil.key \
 && chown postgres.postgres /home/docker/ssl-cert-snakeoil.pem \
 && chown postgres.postgres /home/docker/ssl-cert-snakeoil.key


ADD run.server.sh /home/docker/run.server.sh
ADD run.sql.sh /home/docker/run.sql.sh
RUN chmod +x /home/docker/run.*

ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf



CMD ["/home/docker/run.sh"]