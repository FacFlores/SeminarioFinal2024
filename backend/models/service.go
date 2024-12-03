package models

import (
	"github.com/jinzhu/gorm"
)

type Service struct {
	gorm.Model
	Name           string `json:"name" gorm:"not null"`
	Description    string `json:"description"`
	ConsortiumID   uint   `json:"consortium_id" gorm:"not null"`
	ExpirationDate string `json:"expiration_date" gorm:"not null"`
	Status         string `json:"status" gorm:"default:'active'"`
}
