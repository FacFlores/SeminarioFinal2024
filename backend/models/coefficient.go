package models

import (
	"github.com/jinzhu/gorm"
)

type Coefficient struct {
	gorm.Model
	Name          string `json:"name" gorm:"not null;unique"`
	Distributable bool   `json:"distributable" gorm:"not null"`
}
