FROM ubuntu_base

MAINTAINER GlobAllomeTree "globallometree@fao.org"

RUN wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list
RUN apt-get update 
RUN LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis libpq-dev

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

# ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
ADD startup.sh /home/docker/startup.sh
RUN chmod +x /home/docker/startup.sh

#TODO: Move to Makefile (docker-run)
VOLUME ["/var/lib/postgresql"]
#TODO: Move to Makefile (docker-run)
CMD ["/home/docker/startup.sh"]