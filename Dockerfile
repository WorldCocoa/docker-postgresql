FROM tomgruner/globallometree-ubuntu-base

MAINTAINER Thomas Gruner "tom.gruner@gmail.com"

#Add in the /home/docker directory
ADD startup.sh /home/docker/startup.sh
RUN chmod +x /home/docker/startup.sh

RUN wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list
RUN apt-get update 
RUN LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis libpq-dev

ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf

#Update the servers default ssl certs
RUN LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y ssl-cert
RUN DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil --force-overwrite

RUN cp /etc/ssl/certs/ssl-cert-snakeoil.pem  /home/docker/ssl-cert-snakeoil.pem
RUN cp /etc/ssl/private/ssl-cert-snakeoil.key /home/docker/ssl-cert-snakeoil.key
RUN chown postgres.postgres /home/docker/ssl-cert-snakeoil.pem
RUN chown postgres.postgres /home/docker/ssl-cert-snakeoil.key

CMD ["/home/docker/startup.sh"]
