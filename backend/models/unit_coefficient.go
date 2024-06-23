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
	Percentage    float64     `json:"percentage" gorm:"not null"`
}
