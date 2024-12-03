package models

import "github.com/jinzhu/gorm"

type Reservation struct {
	gorm.Model
	UserID          uint   `json:"user_id" gorm:"not null"`
	ConsortiumID    uint   `json:"consortium_id" gorm:"not null"`
	SpaceID         uint   `json:"space_id" gorm:"not null"`
	Space           Space  `gorm:"foreignKey:SpaceID"`
	ReservationDate string `json:"reservation_date" gorm:"not null"` // Date of reservation (YYYY-MM-DD)
	StartTime       string `json:"start_time" gorm:"not null"`       // Start time (HH:MM)
	EndTime         string `json:"end_time" gorm:"not null"`         // End time (HH:MM)
	Status          string `json:"status" gorm:"default:'active'"`
}
