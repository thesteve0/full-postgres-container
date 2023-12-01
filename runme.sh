#!/bin/sh


initdb

pg_ctl -D /var/lib/postgresql/data -l logfile start

createdb workshop
createdb fire

#gunzip -c crunchy-demo-fire.dump.sql.gz |psql -h localhost -U postgres -p 5432 fire
#gunzip -c crunchy-demo-data.dump.sql.gz |psql -h localhost -U postgres -p 5432 workshop

echo "Downloading sample data"
cd /tmp
wget https://github.com/CrunchyData/crunchy-demo-data/releases/download/v0.3/crunchy_demo_data_v0.3.zip
wget https://github.com/CrunchyData/crunchy-demo-data/releases/download/v0.6/crunchy-demo-data.dump.sql.gz

gunzip -c crunchy-demo-fire.dump.sql.gz |psql fire
gunzip -c crunchy-demo-data.dump.sql.gz |psql workshop

echo "finished"
