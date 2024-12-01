package models

import (
	"github.com/jinzhu/gorm"
)

type Notification struct {
	gorm.Model
	Title              string  `json:"title"`
	Message            string  `json:"message"`
	TargetUserID       *uint   `json:"target_user_id,omitempty"`
	TargetRole         *string `json:"target_role,omitempty"`
	TargetUnitID       *uint   `json:"target_unit_id,omitempty"`
	TargetConsortiumID *uint   `json:"target_consortium_id,omitempty"`
	IsRead             bool    `json:"is_read"`
	SenderUserID       uint    `json:"sender_user_id"`
	SenderUser         User    `json:"sender_user" gorm:"foreignKey:SenderUserID"`
}
