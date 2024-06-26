package models

import (
	"github.com/jinzhu/gorm"
)

type Payment struct {
	gorm.Model
	Amount        float64     `json:"amount" gorm:"not null"`
	Description   string      `json:"description"`
	UnitExpenseID *uint       `json:"unit_expense_id"`
	UnitExpense   UnitExpense `json:"unit_expense" gorm:"foreignKey:UnitExpenseID"`
	TransactionID uint        `json:"transaction_id" gorm:"not null"`
	Transaction   Transaction `json:"transaction" gorm:"foreignKey:TransactionID"`
}
