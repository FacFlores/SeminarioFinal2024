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

func GetRoleByID(id string) (models.Role, error) {
	var role models.Role
	if err := config.DB.First(&role, "id = ?", id).Error; err != nil {
		return role, err
	}
	return role, nil
}

func GetAllRoles() ([]models.Role, error) {
	var roles []models.Role
	if err := config.DB.Find(&roles).Error; err != nil {
		return nil, err
	}
	return roles, nil
}

func CreateRole(role models.Role) (models.Role, error) {
	if err := config.DB.Create(&role).Error; err != nil {
		return role, err
	}
	return role, nil
}

func DeleteRole(id string) error {
	if err := config.DB.Delete(&models.Role{}, id).Error; err != nil {
		return err
	}
	return nil
}
