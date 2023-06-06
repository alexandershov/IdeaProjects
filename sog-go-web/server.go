package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"sog-go-web/database"
	"sog-go-web/model"
)

func main() {
	loadDatabase()
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		var messages []model.Message
		database.Database.Find(&messages)
		c.JSON(200, messages)
	})
	err := r.Run()
	if err != nil {
		fmt.Println(err)
	}
}

func loadDatabase() {
	database.Connect()
	err := database.Database.AutoMigrate(&model.Message{})
	if err != nil {
		panic(err)
	}
}
