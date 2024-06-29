package models

import "github.com/jinzhu/gorm"

type Document struct {
	gorm.Model
	Name         string      `gorm:"not null"`
	ContentType  string      `gorm:"not null"`
	Content      []byte      `gorm:"type:bytea"`
	Visibility   string      `gorm:"not null"` // Visibility level: "public", "unit", "consortium", "admin"
	UnitID       *uint       `gorm:"default:null"`
	Unit         *Unit       `gorm:"foreignKey:UnitID"`
	ConsortiumID *uint       `gorm:"default:null"`
	Consortium   *Consortium `gorm:"foreignKey:ConsortiumID"`
}

const (
	PublicVisibility     = "public"
	UnitVisibility       = "unit"
	ConsortiumVisibility = "consortium"
	AdminVisibility      = "admin"
)

func IsValidVisibility(visibility string) bool {
	switch visibility {
	case PublicVisibility, UnitVisibility, ConsortiumVisibility, AdminVisibility:
		return true
	}
	return false
}
