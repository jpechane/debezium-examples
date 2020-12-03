#!/bin/sh

sudo sh /opt/cassandra/bin/cassandra -f

sed -i 's/^#cdc_raw_directory/cdc_raw_directory/g' /opt/cassandra/conf/cassandra.yaml
sed -i 's/^#cdc_enabled/cdc_enabled/g' /opt/cassandra/conf/cassandra.yaml

java -Dlog4j.debug -Dlog4j.configuration=file:/tmp/log4j.properties -jar /tmp/debezium-connector-cassandra.jar /tmp/config.properties