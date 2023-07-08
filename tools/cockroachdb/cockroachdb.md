## CockroachDB

CockroachDB is a Spanner-like distributed database.

In the absense of True Time based on atomic clocks and GPS CockroachDB uses
[other](https://www.cockroachlabs.com/blog/living-without-atomic-clocks/) time-related tricks.
Spanner delays writes by 7ms, CockroachDB sometimes retries reads.

TODO: understand [this idea](https://cockroachlabs.com/blog/living-without-atomic-clocks/#how-does-cockroachdb-choose-transaction-timestamps)

It provides serializable isolation level.

It's wire compatible with PostgreSQL, so you can use psycopg2/etc to connect to it.

### Start CockroachDB single node cluster

Pull docker image
```shell
docker pull cockroachdb/cockroach:v23.1.5
```

Create docker volume
```shell
docker volume create roach-single
```

Create docker network
```shell
docker network create -d bridge roachnet
```

Start CockroachDB (in insecure mode because we can)
```shell
docker run -d \
  --env COCKROACH_DATABASE=notes \
  --env COCKROACH_USER=aershov \
  --env COCKROACH_PASSWORD=123 \
  --name=roach-single \
  --hostname=roach-single \
  --net=roachnet \
  -p 26257:26257 \
  -p 8080:8080 \
  -v "roach-single:/cockroach/cockroach-data"  \
  cockroachdb/cockroach:v23.1.5 start-single-node \
  --http-addr=localhost:8080 \
  --insecure
```

Since CockroachDB is wire-compatible with PostgreSQL with can use psql to connect to it
```shell
psql -h localhost -p 26257 -U aershov -d notes
```

\dt, CREATE TABLE, etc work in a psql console 