# Debezium Tutorial
This demo automatically deploys the topology of services as defined in [Debezium Tutorial](http://debezium.io/docs/tutorial/) document. A MongoDB is used as a data stource.

How to run:

```shell
# Start the topology as defined in http://debezium.io/docs/tutorial/
export DEBEZIUM_VERSION=0.5
docker-compose up

# Initialize MongoDB replica set
# We should make this automated in Compose environment
docker run --net tutorialmongodb_default -it --name mongo-init --rm -e REPLICASET=rs0 -e MONGO1_PORT_27017_TCP_ADDR=mongo debezium/mongo-initiator:3.2

# Start MongoDB connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register.json

# Consume messages from a Debezium topic
docker-compose exec kafka /kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic dbz.test.mycol

# Modify records in the database via mongo client
docker-compose exec mongo mongo
rs0:PRIMARY> db.mycol.insert({_id: 1, name: "John Doe"})

# Shut down the cluster
docker-compose down
```
