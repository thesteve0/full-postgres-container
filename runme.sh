#!/bin/sh

initdb

pg_ctl -D /var/lib/postgresql/data -l logfile start

createdb workshop


echo "Downloading sample data"
cd /tmp
wget https://github.com/CrunchyData/crunchy-demo-data/releases/download/V0.6.5.1/crunchy-demo-fire.dump.sql.gz
wget https://github.com/CrunchyData/crunchy-demo-data/releases/download/v0.6/crunchy-demo-data.dump.sql.gz

gunzip -c crunchy-demo-data.dump.sql.gz |psql workshop

echo "finished"
