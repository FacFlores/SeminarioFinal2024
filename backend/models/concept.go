package models

import (
	"github.com/jinzhu/gorm"
)

type Concept struct {
	gorm.Model
	Name          string      `json:"name" gorm:"not null"`
	Priority      int         `json:"priority" gorm:"not null"`
	Origin        string      `json:"origin" gorm:"not null"` // "Debe" or "Haber"
	Type          string      `json:"type" gorm:"not null"`
	Description   string      `json:"description"`
	Coefficient   Coefficient `json:"coefficient" gorm:"foreignKey:CoefficientID"`
	CoefficientID uint        `json:"coefficient_id" gorm:"not null"`
}
