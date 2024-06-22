package services

import (
	"backend/config"
	"backend/models"
)

func CreateCoefficient(coefficient models.Coefficient) (models.Coefficient, error) {
	if err := config.DB.Create(&coefficient).Error; err != nil {
		return coefficient, err
	}
	return coefficient, nil
}

func DeleteCoefficient(id string) error {
	if err := config.DB.Delete(&models.Coefficient{}, id).Error; err != nil {
		return err
	}
	return nil
}

func GetCoefficientByID(id string) (models.Coefficient, error) {
	var coefficient models.Coefficient
	if err := config.DB.First(&coefficient, "id = ?", id).Error; err != nil {
		return coefficient, err
	}
	return coefficient, nil
}

func GetAllCoefficients() ([]models.Coefficient, error) {
	var coefficients []models.Coefficient
	if err := config.DB.Find(&coefficients).Error; err != nil {
		return nil, err
	}
	return coefficients, nil
}

func UpdateCoefficient(id string, updatedData models.Coefficient) (models.Coefficient, error) {
	var coefficient models.Coefficient
	if err := config.DB.First(&coefficient, "id = ?", id).Error; err != nil {
		return coefficient, err
	}

	coefficient.Name = updatedData.Name
	coefficient.Distributable = updatedData.Distributable

	if err := config.DB.Save(&coefficient).Error; err != nil {
		return coefficient, err
	}

	return coefficient, nil
}
