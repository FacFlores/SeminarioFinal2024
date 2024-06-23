package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type Bill struct {
	gorm.Model
	BillNumber         int                 `json:"bill_number" gorm:"not null"`
	ConsortiumID       uint                `json:"consortium_id" gorm:"not null"`
	Consortium         Consortium          `json:"consortium" gorm:"foreignKey:ConsortiumID"`
	Period             time.Time           `json:"period" gorm:"not null"`
	ConsortiumExpenses []ConsortiumExpense `json:"consortium_expenses" gorm:"foreignKey:BillID"`
	UnitExpenses       []UnitExpense       `json:"unit_expenses" gorm:"foreignKey:BillID"`
}
