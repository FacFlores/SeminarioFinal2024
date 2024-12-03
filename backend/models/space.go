package models

import "github.com/jinzhu/gorm"

type Space struct {
	gorm.Model
	Name                 string `json:"name" gorm:"not null"`
	ConsortiumID         uint   `json:"consortium_id" gorm:"not null"`
	OperationalStartTime string `json:"operational_start_time" gorm:"not null"`
	OperationalEndTime   string `json:"operational_end_time" gorm:"not null"`
	Status               string `json:"status" gorm:"default:'active'"`
}
