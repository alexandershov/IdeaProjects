/*
 To run:
 ```
    gradlew clean bootJar  # this will create uber jar in build/lib
    DB_URI=jdbc:postgresql://localhost:5432/notes DB_USER=aershov java -jar sog-kotlin-web-0.0.1-SNAPSHOT.jar
 ```
 */

/*
Benchmark results (Kotlin, 1 row returned) (4 cores EC2 + 2 cores RDS):
TLDR: Kotlin can handle 2.5k rps per core
~/wrk/wrk --latency -d 120s -c 200 -t 10 'http://localhost:8080/?name=Jonh'
Running 2m test @ http://localhost:8080/?name=Jonh
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    21.68ms   19.36ms 533.89ms   63.54%
    Req/Sec     1.05k   209.97     1.53k    79.22%
  Latency Distribution
     50%   17.93ms
     75%   32.31ms
     90%   45.12ms
     99%   86.35ms
  1253415 requests in 2.00m, 222.56MB read
Requests/sec:  10440.39
Transfer/sec:      1.85MB

Benchmark results (Kotlin, 100 rows returned) (4 cores EC2 + 2 cores RDS):
TLDR: Kotlin can handle 1.2k rps per core
[ec2-user@ip-172-31-18-69 ~]$ ~/wrk/wrk --latency -d 120s -c 200 -t 10 'http://localhost:8080/?name=Jonh'
Running 2m test @ http://localhost:8080/?name=Jonh
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    54.37ms   55.45ms 610.52ms   83.50%
    Req/Sec   461.39     90.81   790.00     71.18%
  Latency Distribution
     50%   42.04ms
     75%   81.31ms
     90%  122.37ms
     99%  237.60ms
  551484 requests in 2.00m, 4.83GB read
Requests/sec:   4592.20
Transfer/sec:     41.15MB
 */

/*
Benchmark results (Python, 1 row returned) (4 cores EC2 + 2 cores RDS):
TLDR: Python can handle 600 rps per core
~/wrk/wrk --latency -d 120s -c 200 -t 10 'http://localhost:8000/messages'
Running 2m test @ http://localhost:8000/messages
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    70.07ms   21.67ms 419.91ms   89.35%
    Req/Sec   287.67     65.00   470.00     63.30%
  Latency Distribution
     50%   69.69ms
     75%   80.00ms
     90%   99.89ms
     99%  140.06ms
  343814 requests in 2.00m, 61.00MB read
Requests/sec:   2863.87
Transfer/sec:    520.34KB
*/

/* Benchmark results (Python, 1 row returned) (4 cores EC2 + 2 cores RDS):
TLDR: Python can handle 100 rps per core, but that's about 100% cpu usage
~/wrk/wrk --latency -d 120s -c 200 -t 10 'http://localhost:8000/messages'
Running 2m test @ http://localhost:8000/messages
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   389.92ms  383.40ms   2.00s    79.72%
    Req/Sec    50.66     30.11   200.00     62.93%
  Latency Distribution
     50%  169.98ms
     75%  500.01ms
     90%  877.07ms
     99%    1.60s
  59687 requests in 2.00m, 534.39MB read
  Socket errors: connect 0, read 0, write 0, timeout 1791
Requests/sec:    496.98
Transfer/sec:      4.45MB
 */


package com.example.sogkotlinweb

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.*


@SpringBootApplication
class SogKotlinWebApplication


@Table("messages")
data class Message(@Id var id: String, val body: String)

interface MessageRepository : CrudRepository<Message, String>

@RestController
class MessageController(val service: MessageService) {
    @GetMapping("/")
    fun index(@RequestParam("name") name: String) = service.findMessages()
}

@Service
class MessageService(val db: MessageRepository) {
    fun findMessages(): List<Message> = db.findAll().toList()
}

fun main(args: Array<String>) {
    runApplication<SogKotlinWebApplication>(*args)
}
