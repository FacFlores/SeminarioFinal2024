package models

import (
	"github.com/jinzhu/gorm"
)

type Roomer struct {
	gorm.Model
	Name    string `json:"name" gorm:"not null"`
	Surname string `json:"surname" gorm:"not null"`
	Phone   string `json:"phone" gorm:"not null"`
	Dni     string `json:"dni" gorm:"not null;unique"`
	Cuit    string `json:"cuit" gorm:"not null;unique"`
	UserID  *uint  `json:"user_id" gorm:"default:null"`
	User    User   `json:"user" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
}
