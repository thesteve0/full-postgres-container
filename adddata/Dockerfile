FROM ghcr.io/thesteve0/pg16-full

RUN cd /tmp \
    && wget https://github.com/thesteve0/crunchy-demo-data/releases/download/v0.1/crunchy-demo-fire.dump.sql.gz \
    && wget https://github.com/thesteve0/crunchy-demo-data/releases/download/v0.1/crunchy-demo-data.dump.sql.gz
#need to create extensions in the dbs first \
#Need to add vector data
#
#    &&  gunzip -c crunchy-demo-data.dump.sql.gz |psql workshop \
#    &&
#echo "Downloading sample data"
#cd /tmp
#wget https://github.com/CrunchyData/crunchy-demo-data/releases/download/v0.3/crunchy_demo_data_v0.3.zip
#wget https://github.com/CrunchyData/crunchy-demo-data/releases/download/v0.6/crunchy-demo-data.dump.sql.gz
#mkdir /data
#chmod 777 /data
#unzip -u crunchy_demo_data_v0.3.zip -d /data
#mv crunchy-demo-data.dump.sql.gz /data
#rm -f crunchy_demo_data_v0.3.zip