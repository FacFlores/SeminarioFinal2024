package services

import (
	"backend/config"
	"backend/models"
)

func CreateConsortium(consortium models.Consortium) (models.Consortium, error) {
	if err := config.DB.Create(&consortium).Error; err != nil {
		return consortium, err
	}
	return consortium, nil
}

func DeleteConsortium(id string) error {
	if err := config.DB.Delete(&models.Consortium{}, id).Error; err != nil {
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
	if err := config.DB.Find(&consortiums).Error; err != nil {
		return nil, err
	}
	return consortiums, nil
}

func UpdateConsortium(id string, updatedData models.Consortium) (models.Consortium, error) {
	var consortium models.Consortium
	if err := config.DB.First(&consortium, "id = ?", id).Error; err != nil {
		return consortium, err
	}

	consortium.Name = updatedData.Name
	consortium.Address = updatedData.Address
	consortium.Cuit = updatedData.Cuit

	if err := config.DB.Updates(&consortium).Error; err != nil {
		return consortium, err
	}

	return consortium, nil
}
