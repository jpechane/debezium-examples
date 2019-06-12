# Debezium Unwrap MongoDB SMT Demo

This example shows how to capture events from a MongoDB database and stream them to a relational database (Postgres in this case).
In order to convert the CDC events ebitted by Debezium's MongoDB connector into a "flat" structure consumable by the JDBC sink connector, [Debezium MongoDB Event Flattening SMT](http://debezium.io/docs/configuration/mongodb-event-flattening/) is used.

We are using Docker Compose to deploy the following components:

* MongoDB
* Kafka
  * ZooKeeper
  * Kafka Broker
  * Kafka Connect with the [Debezium CDC](http://debezium.io/) and [Elasticsearch sink](https://github.com/confluentinc/kafka-connect-elasticsearch) connectors as well as the Elasticsearch client
* Elasticsearch

## Preparations

```shell
# Start the application
export DEBEZIUM_VERSION=0.10
docker-compose -f docker-compose-es.yaml up --build -d

# Initialize MongoDB replica set and insert some test data
docker-compose exec mongodb bash -c '/usr/local/bin/init-inventory.sh'

# Current host
# if using docker-machine:
export CURRENT_HOST=$(docker-machine ip $(docker-machine active));
# or any other host
# export CURRENT_HOST='localhost' //or your host name 

# Start Elasticsearch sink connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://$CURRENT_HOST:8083/connectors/ -d @es-sink.json

# Start Debezium MongoDB CDC connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://$CURRENT_HOST:8083/connectors/ -d @mongodb-source.json
```

## Verify initial sync

Check contents of the MongoDB database:

```shell
docker-compose -f docker-compose-es.yaml exec mongodb bash -c 'mongo -u $MONGODB_USER -p $MONGODB_PASSWORD --authenticationDatabase admin inventory --eval "db.customers.find()"'

{ "_id" : NumberLong(1001), "first_name" : "Sally", "last_name" : "Thomas", "email" : "sally.thomas@acme.com" }
{ "_id" : NumberLong(1002), "first_name" : "George", "last_name" : "Bailey", "email" : "gbailey@foobar.com" }
{ "_id" : NumberLong(1003), "first_name" : "Edward", "last_name" : "Walker", "email" : "ed@walker.com" }
{ "_id" : NumberLong(1004), "first_name" : "Anne", "last_name" : "Kretchmar", "email" : "annek@noanswer.org" }
```

Verify that the Elasticsearch database has the same content:

```shell
curl "http://$CURRENT_HOST:9200/customers/_search?pretty"

{
  "took" : 0,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 4,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1004",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Anne",
          "last_name" : "Kretchmar",
          "email" : "annek@noanswer.org",
          "id" : 1004
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1001",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Sally",
          "last_name" : "Thomas",
          "email" : "sally.thomas@acme.com",
          "id" : 1001
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1003",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Edward",
          "last_name" : "Walker",
          "email" : "ed@walker.com",
          "id" : 1003
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1002",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "George",
          "last_name" : "Bailey",
          "email" : "gbailey@foobar.com",
          "id" : 1002
        }
      }
    ]
  }
}
```

## Adding a new record

Insert a new record into MongoDB:

```shell
docker-compose -f docker-compose-es.yaml exec mongodb bash -c 'mongo -u $MONGODB_USER -p $MONGODB_PASSWORD --authenticationDatabase admin inventory'

MongoDB server version: 3.4.10
rs0:PRIMARY>

db.customers.insert([
    { _id : NumberLong("1005"), first_name : 'Bob', last_name : 'Hopper', email : 'bob@example.com' }
]);

...
"nInserted" : 1
...
```

Verify that Elasticsearch contains the new record:

```shell
curl "http://$CURRENT_HOST:9200/customers/_search?pretty"

{
  "took" : 0,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 5,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1004",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Anne",
          "last_name" : "Kretchmar",
          "email" : "annek@noanswer.org",
          "id" : 1004
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1001",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Sally",
          "last_name" : "Thomas",
          "email" : "sally.thomas@acme.com",
          "id" : 1001
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1005",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Bob",
          "last_name" : "Hopper",
          "email" : "bob@example.com",
          "id" : 1005
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1003",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Edward",
          "last_name" : "Walker",
          "email" : "ed@walker.com",
          "id" : 1003
        }
      },
      {
        "_index" : "customers",
        "_type" : "customer",
        "_id" : "1002",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "George",
          "last_name" : "Bailey",
          "email" : "gbailey@foobar.com",
          "id" : 1002
        }
      }
    ]
  }
}

```

End application:

```shell
docker-compose -f docker-compose-es.yaml down
```
