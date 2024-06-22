package models

import (
	"github.com/jinzhu/gorm"
)

type Unit struct {
	gorm.Model
	Name         string     `json:"name" gorm:"not null;unique"`
	ConsortiumID uint       `json:"consortium_id" gorm:"not null"`
	Consortium   Consortium `json:"consortium" gorm:"foreignKey:ConsortiumID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Owners       []Owner    `json:"owners" gorm:"many2many:unit_owners;"`
	Roomers      []Roomer   `json:"roomers" gorm:"many2many:unit_roomers;"`
}
