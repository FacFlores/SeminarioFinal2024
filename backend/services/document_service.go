package services

import (
	"backend/config"
	"backend/models"
	"errors"
)

func CreateDocument(document models.Document) (models.Document, error) {
	if !models.IsValidVisibility(document.Visibility) {
		return models.Document{}, errors.New("invalid visibility level")
	}

	if err := config.DB.Create(&document).Error; err != nil {
		return models.Document{}, err
	}

	return document, nil
}

func GetDocumentByID(id string) (models.Document, error) {
	var document models.Document
	if err := config.DB.First(&document, "id = ?", id).Error; err != nil {
		return models.Document{}, err
	}
	return document, nil
}
