FROM cassandra:3.0

RUN apt-get update && \
    apt-get install -y wget curl sudo vim nano git

COPY log4j.properties /tmp/
COPY config.properties /tmp/

ENV DEBEZIUM_VERSION=1.4.0.Alpha2 \
    MAVEN_CENTRAL="https://repo1.maven.org/maven2" \
    CASSANDRA_YAML=/opt/cassandra/conf

RUN for CONNECTOR in {cassandra}; do \
    curl -fSL -o /tmp/debezium-connector-cassandra.jar \
                     $MAVEN_CENTRAL/io/debezium/debezium-connector-$CONNECTOR/$DEBEZIUM_VERSION/debezium-connector-$CONNECTOR-$DEBEZIUM_VERSION-jar-with-dependencies.jar; \
    done;

RUN rm -f $CASSANDRA_YAML/cassandra.yaml
COPY cassandra.yaml $CASSANDRA_YAML/

RUN sed -i 's/^#cdc_raw_directory/cdc_raw_directory/g' $CASSANDRA_YAML/cassandra.yaml
RUN sed -i 's/^#cdc_enabled/cdc_enabled/g' $CASSANDRA_YAML/cassandra.yaml

RUN java -Dlog4j.debug -Dlog4j.configuration=file:/tmp/log4j.properties -jar /tmp/debezium-connector-cassandra.jar /tmp/config.properties

RUN sed -i 's/^cdc_raw_directory/#cdc_raw_directory/g' $CASSANDRA_YAML/cassandra.yaml
RUN sed -i 's/^cdc_enabled/#cdc_enabled/g' $CASSANDRA_YAML/cassandra.yaml





