package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type Consortium struct {
	gorm.Model
	Name       string              `json:"name" gorm:"not null;unique"`
	Address    string              `json:"address" gorm:"not null"`
	Cuit       string              `json:"cuit"`
	BillNumber uint                `json:"bill_number" gorm:"default:0"`
	Services   []ConsortiumService `json:"services" gorm:"foreignKey:ConsortiumID"`
	Units      []Unit              `json:"units" gorm:"foreignKey:ConsortiumID"`
}

func (Consortium) TableName() string {
	return "consortiums"
}

type ConsortiumService struct {
	gorm.Model
	ConsortiumID    uint       `json:"consortium_id" gorm:"not null"`
	Consortium      Consortium `json:"consortium" gorm:"foreignKey:ConsortiumID"`
	Name            string     `json:"name" gorm:"not null"`
	Description     string     `json:"description"`
	ScheduledDate   time.Time  `json:"scheduled_date" gorm:"not null"`
	NextMaintenance time.Time  `json:"next_maintenance"`
	ExpiryDate      time.Time  `json:"expiry_date"`
	Status          string     `json:"status" gorm:"not null"` // e.g., "Scheduled", "Completed", "Overdue"
}
