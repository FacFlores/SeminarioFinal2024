package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type User struct {
	gorm.Model
	Name           string    `json:"name" gorm:"not null"`
	Email          string    `json:"email" gorm:"not null;unique"`
	Surname        string    `json:"surname" gorm:"not null"`
	Phone          string    `json:"phone" gorm:"not null"`
	Dni            string    `json:"dni" gorm:"not null;unique"`
	RoleID         uint      `json:"role_id" gorm:"not null"`
	Role           Role      `json:"role" gorm:"foreignKey:RoleID"`
	Password       string    `json:"password" gorm:"not null"`
	LastLogin      time.Time `json:"last_login"`
	ProfilePicture string    `json:"profile_picture"`
	IsActive       bool      `json:"is_active" gorm:"default:true"`
}
