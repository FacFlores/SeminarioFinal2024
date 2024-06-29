package models

import (
	"github.com/jinzhu/gorm"
)

type Notification struct {
	gorm.Model
	UserID             uint   `gorm:"not null"` // Sender of the notification
	User               User   `gorm:"foreignKey:UserID"`
	Message            string `gorm:"not null"`
	IsRead             bool   `gorm:"default:false"` // Flag to mark if the notification has been read
	TargetRole         string `gorm:"not null"`      // Role targeted for the notification (e.g., "admin", "consortium")
	TargetUnitID       uint   `gorm:"default:null"`
	TargetConsortiumID uint   `gorm:"default:null"`
}
