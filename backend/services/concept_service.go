package services

import (
	"backend/config"
	"backend/models"
)

func CreateConcept(concept models.Concept) (models.Concept, error) {
	if err := config.DB.Create(&concept).Error; err != nil {
		return concept, err
	}
	return concept, nil
}

func DeleteConcept(id string) error {
	if err := config.DB.Delete(&models.Concept{}, id).Error; err != nil {
		return err
	}
	return nil
}

func GetConceptByID(id string) (models.Concept, error) {
	var concept models.Concept
	if err := config.DB.Preload("Coefficient").First(&concept, "id = ?", id).Error; err != nil {
		return concept, err
	}
	return concept, nil
}

func GetAllConcepts() ([]models.Concept, error) {
	var concepts []models.Concept
	if err := config.DB.Preload("Coefficient").Find(&concepts).Error; err != nil {
		return nil, err
	}
	return concepts, nil
}

func UpdateConcept(id string, updatedData models.Concept) (models.Concept, error) {
	var concept models.Concept
	if err := config.DB.First(&concept, "id = ?", id).Error; err != nil {
		return concept, err
	}

	concept.Name = updatedData.Name
	concept.Priority = updatedData.Priority
	concept.Origin = updatedData.Origin
	concept.Type = updatedData.Type
	concept.Description = updatedData.Description
	concept.CoefficientID = updatedData.CoefficientID

	if err := config.DB.Save(&concept).Error; err != nil {
		return concept, err
	}

	return concept, nil
}
