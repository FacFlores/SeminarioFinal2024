package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type ConsortiumExpense struct {
	gorm.Model
	Description     string     `json:"description"`
	BillNumber      uint       `json:"bill_number" gorm:"not null"`
	Amount          float64    `json:"amount" gorm:"not null"`
	ConceptID       uint       `json:"concept_id" gorm:"not null"`
	Concept         Concept    `json:"concept" gorm:"foreignKey:ConceptID"`
	ExpensePeriod   time.Time  `json:"expense_period" gorm:"not null"`
	LiquidatePeriod time.Time  `json:"liquidate_period"`
	Distributed     bool       `json:"distributed" gorm:"not null"`
	ConsortiumID    uint       `json:"consortium_id" gorm:"not null"`
	Consortium      Consortium `json:"consortium" gorm:"foreignKey:ConsortiumID"`
}
