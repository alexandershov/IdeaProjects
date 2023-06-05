/*
 To run:
 ```
    gradlew clean bootJar  # this will create uber jar in build/lib
    DB_URI=jdbc:postgresql://localhost:5432/notes DB_USER=aershov java -jar sog-kotlin-web-0.0.1-SNAPSHOT.jar
 ```
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
