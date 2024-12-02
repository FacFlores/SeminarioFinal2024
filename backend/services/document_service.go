package services

import (
	"backend/config"
	"backend/models"
	"errors"
	"fmt"
	"io/ioutil"
	"mime/multipart"
	"os"
	"path/filepath"
	"time"
)

func UploadDocument(consortiumID, unitID *uint, documentType, name string, file multipart.File) (models.Document, error) {
	uniqueName := fmt.Sprintf("%s-%d%s", name, time.Now().Unix(), ".pdf")
	uploadDir := "uploads/documents/"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return models.Document{}, err
	}
	filePath := filepath.Join(uploadDir, uniqueName)
	dst, err := os.Create(filePath)
	if err != nil {
		return models.Document{}, err
	}
	defer dst.Close()
	fileBytes, err := ioutil.ReadAll(file)
	if err != nil {
		return models.Document{}, err
	}
	_, err = dst.Write(fileBytes)
	if err != nil {
		return models.Document{}, err
	}
	document := models.Document{
		Name:         name,
		ContentType:  documentType,
		FilePath:     filePath,
		UnitID:       unitID,
		ConsortiumID: consortiumID,
	}
	if err := config.DB.Create(&document).Error; err != nil {
		return models.Document{}, err
	}
	return document, nil
}

func GetDocumentsByConsortium(consortiumID uint) ([]models.Document, error) {
	var documents []models.Document
	if err := config.DB.Where("consortium_id = ?", consortiumID).Find(&documents).Error; err != nil {
		return nil, err
	}
	return documents, nil
}
func GetDocumentsByUnit(unitID uint) ([]models.Document, error) {
	var documents []models.Document
	if err := config.DB.Where("unit_id = ?", unitID).Find(&documents).Error; err != nil {
		return nil, err
	}
	return documents, nil
}
func GetDocumentByName(documentName string) (models.Document, error) {
	var document models.Document
	if err := config.DB.Where("name = ?", documentName).First(&document).Error; err != nil {
		return document, err
	}
	return document, nil
}
func GetAllDocuments() ([]models.Document, error) {
	var documents []models.Document
	if err := config.DB.Preload("Unit").Preload("Consortium").Find(&documents).Error; err != nil {
		return nil, err
	}
	return documents, nil
}

func DeleteDocumentByID(documentID uint) error {
	var document models.Document
	if err := config.DB.First(&document, documentID).Error; err != nil {
		return errors.New("document not found")
	}
	if err := config.DB.Delete(&document).Error; err != nil {
		return err
	}
	err := os.Remove(document.FilePath)
	if err != nil {
		return err
	}
	return nil
}

func GetDocumentByID(documentID uint) (models.Document, error) {
	var document models.Document
	if err := config.DB.First(&document, documentID).Error; err != nil {
		return document, errors.New("document not found")
	}
	return document, nil
}
