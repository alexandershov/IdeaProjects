## Apache Flink

Apache Flink is a stream processing framework.
Flink jobs take several input stream, transform them in some way and produce
several output streams.

```shell
export FLINK_PROPERTIES="jobmanager.rpc.address: jobmanager"
```

Create docker network for Flink

```shell
docker network create flink-network
```

Start flink Job Manager.

```shell
docker run \
--rm \
--name=jobmanager \
--network flink-network \
--publish 8081:8081 \
--env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
flink:latest jobmanager
```

Job Manager, well, manages jobs. The jobs themselves run on Task Managers.

Start Flink Task Manager

```shell
docker run \
    --rm \
    --name=taskmanager \
    --network flink-network \
    --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
    flink:latest taskmanager
```

Run example job

```shell
docker exec -it {job_manager_container_id} /bin/bash
./bin/flink run ./examples/streaming/TopSpeedWindowing.jar
```

Flink has a web-interface on http://localhost:8081 where you see the progress
of your jobs.
