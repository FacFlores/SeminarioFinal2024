package models

import (
	"github.com/jinzhu/gorm"
)

type Consortium struct {
	gorm.Model
	Name       string `json:"name" gorm:"not null;unique"`
	Address    string `json:"address" gorm:"not null"`
	Cuit       string `json:"cuit"`
	BillNumber uint   `json:"bill_number" gorm:"default:0"`
}

func (Consortium) TableName() string {
	return "consortiums"
}
