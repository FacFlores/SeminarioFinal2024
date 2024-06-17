package models

import "github.com/jinzhu/gorm"

type User struct {
	gorm.Model
	Name     string `json:"name" gorm:"not null"`
	Email    string `json:"email" gorm:"not null;unique"`
	Surname  string `json:"surname" gorm:"not null"`
	Phone    string `json:"phone" gorm:"not null"`
	Dni      string `json:"dni" gorm:"not null;unique"`
	Role     int    `json:"role" gorm:"not null"`
	Password string `json:"password" gorm:"not null"`
}
