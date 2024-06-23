package models

import (
	"github.com/jinzhu/gorm"
)

type UnitLedger struct {
	gorm.Model
	UnitID  uint    `json:"unit_id" gorm:"not null"`
	Unit    Unit    `json:"unit" gorm:"foreignKey:UnitID"`
	Balance float64 `json:"balance" gorm:"not null"`
}
