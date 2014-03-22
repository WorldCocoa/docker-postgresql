FROM tomgruner/globallometree-base

MAINTAINER Thomas Gruner "tom.gruner@gmail.com"

ENV LC_ALL en_US.UTF-8 
ENV	DEBIAN_FRONTEND noninteractive

ADD run.sh /home/docker/run.sh
ADD run.config.sh /home/docker/run.config.sh
ADD run.sql_statement.sh /home/docker/run.sql_statement.sh
RUN chmod +x /home/docker/run.*

RUN wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
	postgresql-9.3 \
	postgresql-contrib-9.3 \
	postgresql-9.3-postgis \
	libpq-dev \
	ssl-cert

ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf

#Update the servers default ssl certs
RUN make-ssl-cert generate-default-snakeoil --force-overwrite

RUN cp /etc/ssl/certs/ssl-cert-snakeoil.pem  /home/docker/ssl-cert-snakeoil.pem \ 
 && cp /etc/ssl/private/ssl-cert-snakeoil.key /home/docker/ssl-cert-snakeoil.key \
 && chown postgres.postgres /home/docker/ssl-cert-snakeoil.pem \
 && chown postgres.postgres /home/docker/ssl-cert-snakeoil.key

CMD ["/home/docker/run.sh"]