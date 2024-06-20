package models

import "github.com/jinzhu/gorm"

type Role struct {
	gorm.Model
	Name        string `json:"name" gorm:"not null;unique"`
	Description string `json:"description"`
}
