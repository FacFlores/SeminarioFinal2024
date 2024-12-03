package services

import (
	"backend/config"
	"backend/models"
	"fmt"
)

func CreateSpace(space *models.Space) error {
	if err := config.DB.Create(space).Error; err != nil {
		return fmt.Errorf("could not create space: %v", err)
	}
	return nil
}

func GetSpacesByConsortium(consortiumID uint) ([]models.Space, error) {
	var spaces []models.Space
	if err := config.DB.Where("consortium_id = ?", consortiumID).Find(&spaces).Error; err != nil {
		return nil, fmt.Errorf("could not retrieve spaces: %v", err)
	}
	return spaces, nil
}

func UpdateSpace(spaceID uint, input map[string]interface{}) error {
	if err := config.DB.Model(&models.Space{}).Where("id = ?", spaceID).Updates(input).Error; err != nil {
		return fmt.Errorf("could not update space: %v", err)
	}
	return nil
}

func DeleteSpace(spaceID uint) error {
	if err := config.DB.Delete(&models.Space{}, spaceID).Error; err != nil {
		return fmt.Errorf("could not delete space: %v", err)
	}
	return nil
}
