package services

import (
	"backend/config"
	"backend/models"
	"fmt"

	"gorm.io/gorm"
)

func CreateServiceForConsortium(service *models.Service) error {
	if service.Name == "" || service.ExpirationDate == "" || service.ConsortiumID == 0 {
		return fmt.Errorf("invalid input")
	}
	if err := config.DB.Create(service).Error; err != nil {
		return fmt.Errorf("could not create service: %v", err)
	}
	return nil
}

func GetAllServices() ([]models.Service, error) {
	var services []models.Service
	if err := config.DB.Find(&services).Error; err != nil {
		return nil, fmt.Errorf("could not retrieve services: %v", err)
	}
	return services, nil
}

func GetServicesByConsortium(consortiumID string) ([]models.Service, error) {
	var services []models.Service
	if err := config.DB.Where("consortium_id = ?", consortiumID).Find(&services).Error; err != nil {
		return nil, fmt.Errorf("could not retrieve services for consortium %s: %v", consortiumID, err)
	}
	return services, nil
}

func UpdateService(serviceID string, service *models.Service) error {
	var existingService models.Service
	if err := config.DB.Where("id = ?", serviceID).First(&existingService).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return fmt.Errorf("service not found")
		}
		return fmt.Errorf("could not retrieve service: %v", err)
	}

	if service.Name != "" {
		existingService.Name = service.Name
	}
	if service.Description != "" {
		existingService.Description = service.Description
	}
	if service.ExpirationDate != "" {
		existingService.ExpirationDate = service.ExpirationDate
	}
	if service.Status != "" {
		existingService.Status = service.Status
	}

	if err := config.DB.Save(&existingService).Error; err != nil {
		return fmt.Errorf("could not update service: %v", err)
	}
	return nil
}

func DeleteServiceByID(serviceID string) error {
	if err := config.DB.Where("id = ?", serviceID).Delete(&models.Service{}).Error; err != nil {
		return fmt.Errorf("could not delete service: %v", err)
	}
	return nil
}
