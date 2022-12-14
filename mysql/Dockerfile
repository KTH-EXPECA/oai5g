FROM mysql:5.7

COPY database/oai_db2.sql /docker-entrypoint-initdb.d/oai_db.sql

ENV TZ=Europe/Paris
ENV MYSQL_DATABASE=oai_db
ENV MYSQL_USER=test
ENV MYSQL_PASSWORD=test
ENV MYSQL_ROOT_PASSWORD=linux
