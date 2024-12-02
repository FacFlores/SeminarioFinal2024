package models

import "github.com/jinzhu/gorm"

type Document struct {
	gorm.Model
	Name         string      `gorm:"not null"`
	ContentType  string      `gorm:"not null"`
	FilePath     string      `gorm:"not null"`
	UnitID       *uint       `gorm:"default:null"`
	Unit         *Unit       `gorm:"foreignKey:UnitID"`
	ConsortiumID *uint       `gorm:"default:null"`
	Consortium   *Consortium `gorm:"foreignKey:ConsortiumID"`
}
