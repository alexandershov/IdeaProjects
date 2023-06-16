import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.ConsumerRecords
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.serialization.StringDeserializer
import java.time.Duration
import java.util.*

fun checkKafka() {
    // prerequisites: start kafka using instructions in kafka.md
    val props = Properties()
    props[ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG] = "localhost:9094"
    props[ConsumerConfig.GROUP_ID_CONFIG] = "test"
    // start from the beginning of the topic when consumer is started for the first time
    props[ConsumerConfig.AUTO_OFFSET_RESET_CONFIG] = "earliest"
    // Keys are used to partition messages
    props[ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG] = StringDeserializer::class.java
    // Values are the messages themselves
    props[ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG] = StringDeserializer::class.java

    KafkaConsumer<String, String>(props).use { consumer ->
        consumer.subscribe(listOf("payment-events")) // specify the list of topics to consume from

        while (true) {
            println("Polling messages from topic payment-events")
            // poll will not throw an error if network is unreachable, bad API
            val records: ConsumerRecords<String, String> = consumer.poll(Duration.ofMillis(5000)) // poll new events
            for (record in records) {
                println("Received message: ${record.value()} at offset ${record.offset()}") // print out the record's value
            }
        }
    }
}
