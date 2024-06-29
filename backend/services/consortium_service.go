package services

import (
	"backend/config"
	"backend/models"
	"time"
)

func CreateConsortium(consortium models.Consortium) (models.Consortium, error) {
	if err := config.DB.Create(&consortium).Error; err != nil {
		return consortium, err
	}
	return consortium, nil
}

func DeleteConsortium(id string) error {
	result := config.DB.Unscoped().Model(&models.Consortium{}).Where("id = ?", id).Update("deleted_at", time.Now())
	if err := result.Error; err != nil {
		return err
	}

	return nil
}

func GetConsortiumByUnit(unitID uint) (models.Consortium, error) {
	var unit models.Unit
	if err := config.DB.First(&unit, unitID).Error; err != nil {
		return models.Consortium{}, err
	}

	var consortium models.Consortium
	if err := config.DB.First(&consortium, unit.ConsortiumID).Error; err != nil {
		return consortium, err
	}
	return consortium, nil
}

func GetConsortiumByID(id string) (models.Consortium, error) {
	var consortium models.Consortium
	if err := config.DB.First(&consortium, "id = ?", id).Error; err != nil {
		return consortium, err
	}
	return consortium, nil
}

func GetConsortiumByName(name string) (models.Consortium, error) {
	var consortium models.Consortium
	if err := config.DB.Where("name = ?", name).First(&consortium).Error; err != nil {
		return consortium, err
	}
	return consortium, nil
}

func GetAllConsortiums() ([]models.Consortium, error) {
	var consortiums []models.Consortium
	if err := config.DB.Where("deleted_at IS NULL").Find(&consortiums).Error; err != nil {
		return nil, err
	}
	return consortiums, nil
}

func UpdateConsortium(id uint, updatedData models.Consortium) (models.Consortium, error) {
	var consortium models.Consortium
	if err := config.DB.First(&consortium, "id = ?", id).Error; err != nil {
		return consortium, err
	}

	consortium.Name = updatedData.Name
	consortium.Address = updatedData.Address
	consortium.Cuit = updatedData.Cuit
	consortium.BillNumber = updatedData.BillNumber

	if err := config.DB.Updates(&consortium).Error; err != nil {
		return consortium, err
	}

	return consortium, nil
}

func CreateConsortiumService(consortiumID uint, name, description string, scheduledDate, expiryDate time.Time) (*models.ConsortiumService, error) {
	service := models.ConsortiumService{
		ConsortiumID:    consortiumID,
		Name:            name,
		Description:     description,
		ScheduledDate:   scheduledDate,
		NextMaintenance: scheduledDate, // Assuming first maintenance is the scheduled date
		ExpiryDate:      expiryDate,
		Status:          "Completed",
	}
	if err := config.DB.Create(&service).Error; err != nil {
		return nil, err
	}
	return &service, nil
}

func GetConsortiumServices(consortiumID uint) ([]models.ConsortiumService, error) {
	var services []models.ConsortiumService
	if err := config.DB.Where("consortium_id = ?", consortiumID).Find(&services).Error; err != nil {
		return nil, err
	}
	return services, nil
}

func UpdateConsortiumServiceStatus(serviceID uint, status string) error {
	return config.DB.Model(&models.ConsortiumService{}).Where("id = ?", serviceID).Update("status", status).Error
}

func ScheduleNextMaintenance(serviceID uint, nextMaintenance time.Time) error {
	return config.DB.Model(&models.ConsortiumService{}).Where("id = ?", serviceID).Update("next_maintenance", nextMaintenance).Error
}
