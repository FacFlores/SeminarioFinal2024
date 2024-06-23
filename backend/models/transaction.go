package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type Transaction struct {
	gorm.Model
	UnitLedgerID uint        `json:"unit_ledger_id" gorm:"not null"`
	UnitLedger   UnitLedger  `json:"unit_ledger" gorm:"foreignKey:UnitLedgerID"`
	Amount       float64     `json:"amount" gorm:"not null"`
	Description  string      `json:"description"`
	Date         time.Time   `json:"date" gorm:"not null"`
	ConceptID    uint        `json:"concept_id" gorm:"not null"`
	Concept      Concept     `json:"concept" gorm:"foreignKey:ConceptID"`
	ExpenseID    *uint       `json:"expense_id"`
	Expense      UnitExpense `json:"expense" gorm:"foreignKey:ExpenseID"`
}

func (t *Transaction) BeforeCreate(tx *gorm.DB) (err error) {
	if t.Date.IsZero() {
		t.Date = time.Now()
	}
	return
}
