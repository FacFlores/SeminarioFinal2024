package services

import (
	"backend/config"
	"backend/models"
)

func GetRoleByName(name string) (models.Role, error) {
	var role models.Role
	if err := config.DB.Where("name = ?", name).First(&role).Error; err != nil {
		return role, err
	}
	return role, nil
}
