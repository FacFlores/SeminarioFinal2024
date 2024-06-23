package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type UnitExpense struct {
	gorm.Model
	Description         string            `json:"description"`
	BillNumber          uint              `json:"bill_number" gorm:"not null"`
	Amount              float64           `json:"amount" gorm:"not null"`
	LeftToPay           float64           `json:"left_to_pay" gorm:"not null"`
	ConceptID           uint              `json:"concept_id" gorm:"not null"`
	Concept             Concept           `json:"concept" gorm:"foreignKey:ConceptID"`
	ExpensePeriod       time.Time         `json:"expense_period" gorm:"not null"`
	LiquidatePeriod     time.Time         `json:"liquidate_period"`
	Liquidated          bool              `json:"liquidated" gorm:"not null"`
	Paid                bool              `json:"paid" gorm:"not null"`
	UnitID              uint              `json:"unit_id" gorm:"not null"`
	Unit                Unit              `json:"unit" gorm:"foreignKey:UnitID"`
	ConsortiumExpenseID *uint             `json:"consortium_expense_id"`
	ConsortiumExpense   ConsortiumExpense `json:"consortium_expense" gorm:"foreignKey:ConsortiumExpenseID"`
}
