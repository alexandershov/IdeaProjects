package model

import "gorm.io/gorm"

type Message struct {
	gorm.Model
	Id   string `gorm:"size:255;not null;unique" json:"id"`
	Body string `gorm:"size:255;not null;unique" json:"body"`
}
