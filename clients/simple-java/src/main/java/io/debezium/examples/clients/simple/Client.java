package io.debezium.examples.clients.simple;

import java.io.StringReader;
import java.util.Arrays;
import java.util.Collections;
import java.util.Properties;
import java.util.UUID;

import javax.json.Json;
import javax.json.JsonObject;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.OffsetResetStrategy;
import org.apache.kafka.connect.data.SchemaAndValue;
import org.apache.kafka.connect.data.Struct;
import org.apache.kafka.connect.json.JsonConverter;

public class Client {
    private static final String KAFKA_BROKER = "kafka.broker";
    private static final String KAFKA_CLIENT_ID = "kafka.client.id";
    private static final String KAFKA_TOPIC = "kafka.topic";

    final JsonConverter valueConverter = new JsonConverter();
    private String kafkaTopic;

    public Client() {
        valueConverter.configure(Collections.emptyMap(), false);
        kafkaTopic = System.getProperty(KAFKA_TOPIC);
        if (kafkaTopic == null) {
            throw new IllegalStateException("Property '" + KAFKA_TOPIC + "' was not configured");
        }
    }

    private KafkaConsumer<String, String> createConsumer() {
        final String clientName = System.getProperty(KAFKA_CLIENT_ID, UUID.randomUUID().toString());

        final Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, System.getProperty(KAFKA_BROKER, "localhost:9092"));
        props.put(ConsumerConfig.CLIENT_ID_CONFIG, clientName);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, clientName);
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");
        props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "1000");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, OffsetResetStrategy.EARLIEST.toString().toLowerCase());
        return new KafkaConsumer<>(props);
    }

    public void run() {
        try (final KafkaConsumer<String, String> consumer = createConsumer()) {
            consumer.subscribe(Arrays.asList(kafkaTopic));
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(500);
                for (ConsumerRecord<String, String> record : records) {
                    plainConsumer(record);
                    connectConsumer(record);
                }
            }
        }
    }

    private void plainConsumer(ConsumerRecord<String, String> record) {
        final JsonObject message = Json.createReader(new StringReader(record.value())).readObject();
        final JsonObject newValue = message.getJsonObject("payload").getJsonObject("after");
        System.out.println(" ===== New value via JSON =====");
        newValue.forEach((k, v) -> System.out.println(k + " = " + v));
        System.out.println(" =====================");
    }

    private void connectConsumer(ConsumerRecord<String, String> record) {
        final SchemaAndValue message = valueConverter.toConnectData("aa", record.value().getBytes());
        final Struct payload = (Struct)message.value();
        final Struct newValue = payload.getStruct("after");
        System.out.println(" ===== New value via Connect API =====");
        newValue.schema().fields().forEach(x -> System.out.println(x.name() + "(" + x.schema().type().getName() + ")" + " = " + newValue.get(x)));
        System.out.println(" =====================");
    }

    public static void main(String[] args) {
        new Client().run();
    }

}
