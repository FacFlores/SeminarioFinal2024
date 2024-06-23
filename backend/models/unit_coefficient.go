package models

import (
	"github.com/jinzhu/gorm"
)

type UnitCoefficient struct {
	gorm.Model
	UnitID        uint        `json:"unit_id" gorm:"not null"`
	Unit          Unit        `json:"unit" gorm:"foreignKey:UnitID"`
	CoefficientID uint        `json:"coefficient_id" gorm:"not null" validate:"required"`
	Coefficient   Coefficient `json:"coefficient" gorm:"foreignKey:CoefficientID"`
	ConsortiumID  uint        `json:"consortium_id" gorm:"not null"`
	Consortium    Consortium  `json:"consortium" gorm:"foreignKey:ConsortiumID"`
	Percentage    float64     `json:"percentage" gorm:"not null"`
}
