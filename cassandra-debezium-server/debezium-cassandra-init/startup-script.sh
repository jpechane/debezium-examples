#!/bin/sh

sh /opt/cassandra/bin/cassandra -f &

while ! grep -q "Created default superuser role 'cassandra" /opt/cassandra/logs/system.log
do
  sleep 1
done;

cqlsh -f $DEBEZIUM_HOME/inventory.cql

while true;
do
  sleep 1
done;
