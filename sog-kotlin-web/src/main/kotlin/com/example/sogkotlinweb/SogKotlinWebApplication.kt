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
