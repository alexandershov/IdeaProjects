Pull kafka docker image

```shell
docker pull bitnami/kafka:latest
```

Start the container

```shell
docker run -e ALLOW_PLAINTEXT_LISTENER=yes -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093,EXTERNAL://:9094 -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092,EXTERNAL://localhost:9094 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT -p 9092:9092 -p 9094:9094 --name kafka bitnami/kafka
```

Connect to container

```shell
docker exec -it kafka /bin/bash
```

Create a topic

```shell
kafka-topics.sh --create --topic payment-events --bootstrap-server localhost:9094
```

Produce events

```shell
echo -e 'first\nsecond' | kafka-console-producer.sh --topic payment-events --bootstrap-server localhost:9094
```

Consume events:

```shell
kafka-console-consumer.sh --from-beginning --topic payment-events --bootstrap-server localhost:9094
```