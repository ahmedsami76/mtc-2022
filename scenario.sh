#!/bin/bash -x

echo "1- Spinning up the Docker Compose services ..."
docker-compose -f docker-compose.yml up -d

sleep 30

echo "2- Restoring SQL Server database..."
docker-compose exec  sql-db  /opt/mssql-tools/bin/sqlcmd -s localhost -U sa -P P@ssw0rd -Q 'restore database adworks from disk = "/data/sql-db/AdventureWorksLT2019.bak" with move "AdventureWorksLT2012_Data" to "/var/opt/mssql/data/AdventureWorksLT2012.mdf", move "AdventureWorksLT2012_Log" to "/var/opt/mssql/data/AdventureWorksLT2012_log.ldf", REPLACE'

echo "3- Restoring PostgreSQL database..."
docker-compose exec pg-db psql -U postgres -c "CREATE DATABASE dvdrental;" && docker-compose exec pg-db pg_restore -U postgres -d dvdrental /data/pg-db/dvdrental.tar

echo "4- Loading JDBC drivers and installing required Python Modules..."
docker-compose exec spark sh /data/pyodbc.sh
docker-compose exec spark cp /data/sql-db/sqljdbc42.jar /usr/local/spark/jars
docker-compose exec spark cp /data/pg-db/postgresql-42.4.1.jar /usr/local/spark/jars

docker-compose exec spark pip install -r /data/requirements.txt

echo "5- Running Jupyter Lab..."
docker-compose exec spark jupyter-lab --no-browser --allow-root --ip 0.0.0.0 /data/

