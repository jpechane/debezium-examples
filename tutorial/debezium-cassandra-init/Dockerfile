FROM cassandra:3.0

RUN apt-get update && \
    apt-get install -y wget curl sudo vim nano git gnupg

RUN sudo apt install -y openjdk-8-jdk

COPY log4j.properties /tmp/
COPY config.properties /tmp/

ENV DEBEZIUM_VERSION=1.4.0.Alpha2 \
    MAVEN_CENTRAL="https://repo1.maven.org/maven2" \
    CASSANDRA_YAML=/opt/cassandra/conf

RUN rm -f $CASSANDRA_YAML/cassandra.yaml
COPY cassandra.yaml $CASSANDRA_YAML/

RUN for CONNECTOR in {cassandra}; do \
    curl -fSL -o /tmp/debezium-connector-cassandra.jar \
                     $MAVEN_CENTRAL/io/debezium/debezium-connector-$CONNECTOR/$DEBEZIUM_VERSION/debezium-connector-$CONNECTOR-$DEBEZIUM_VERSION-jar-with-dependencies.jar; \
    done;

ADD startup-script.sh /tmp/startup-script.sh
RUN chmod +x /tmp/startup-script.sh
CMD /tmp/startup-script.sh


