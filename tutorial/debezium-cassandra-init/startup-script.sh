#!/bin/sh

sh /opt/cassandra/bin/cassandra -f &

sleep 20

java -Dlog4j.debug -Dlog4j.configuration=file:$DEBEZIUM_HOME/log4j.properties -jar $DEBEZIUM_HOME/debezium-connector-cassandra.jar $DEBEZIUM_HOME/config.properties
