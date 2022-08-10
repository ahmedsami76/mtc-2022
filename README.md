# use to create a demo for on-prem spark/hadoop analytics with sql, pg and python spokes.

## notes  
The docker compose uses 3 services:  
* Microsoft SQL Server 2019 (sql-db)
* PostgreSQL (pg-db)
* Apache Spark 3.3.3 with Hadoop 3.3.1 and also has Jupyter installed (spark)


## 1- Use hoster service  
This is a standalone container to provide name resolution between docker host and containers and to avoid exposing ports  
Run the following to pull and start the container:  
`docker run -d -v /var/run/docker.sock:/tmp/docker.sock -v /etc/hosts:/tmp/hosts asami76/docker-hoster`


## 2- Spin up the docker compose services
`docker-compose -f docker-compose.yml up -d`  


## 3- Restore AdventureWorks DB in sql container  
The AdventureWorks DB backup file is placed in the `/data/sql-db/` dir  
Note: You may need to wait for a couple of minutes before restoring the db to ensure the PG daemons are already up    
To restore into the sql-db service in Docker Compose:  
`docker-compose exec  sql-db  /opt/mssql-tools/bin/sqlcmd -s localhost -U sa -P P@ssw0rd -Q 'restore database nwtraders from disk = "/data/sql-db/AdventureWorksLT2019.bak" with move "AdventureWorksLT2012_Data" to "/var/opt/mssql/data/AdventureWorksLT2012.mdf", move "AdventureWorksLT2012_Log" to "/var/opt/mssql/data/AdventureWorksLT2012_log.ldf", REPLACE'`  

`docker-compose exec  sql-db  /opt/mssql-tools/bin/sqlcmd -s localhost -U sa -P P@ssw0rd -Q 'restore database AdventureWorks from disk = "/data/sql-db/AdventureWorks2019.bak" with move "AdventureWorks2017" to "/var/opt/mssql/data/AdventureWorks2019.mdf", move "AdventureWorks2017_Log" to "/var/opt/mssql/data/AdventureWorks2019_log.ldf", REPLACE'`


## 4- Restore dvdrental DB in postgres container
The dvdrental backup file is placed in the '/data/pg-db/` dir  
Note: You may need to wait for a couple of minutes before restoring the db to ensure the SQL services are already up    
To restore into the pg-db container from docker-compose:  
`docker-compose exec pg-db psql -U postgres -c "CREATE DATABASE dvdrental;" && docker-compose exec pg-db pg_restore -U postgres -d dvdrental /data/pg-db/dvdrental.tar`


## 5- Install required modules and drivers
to install mssql driver
`docker-compose exec spark sh /data/pyodbc.sh`  
`docker-compose exec spark cp /data/sql-db/sqljdbc42.jar /usr/local/spark/jars`  
`docker-compose exec spark cp /data/pg-db/postgresql-42.4.1.jar /usr/local/spark/jars`  

to install the required python packages
`docker-compose exec spark pip install -r /data/requirements.txt`  



## 6. Start Jupyter Lab to connect to spark
to be able to use Jupyter Notebook to connect to the Spark standalone cluster in the container rather than using the pyspark shell run the following:  
`docker-compose exec spark jupyter-lab --no-browser --allow-root --ip 0.0.0.0 /data/`  
Then copy the provided link to open Jupyter Lab from the Docker host's browser