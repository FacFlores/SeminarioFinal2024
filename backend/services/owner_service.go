package services

import (
	"backend/config"
	"backend/models"
)

func CreateOwner(owner models.Owner) (models.Owner, error) {
	if err := config.DB.Create(&owner).Error; err != nil {
		return owner, err
	}
	return owner, nil
}

func DeleteOwner(id string) error {
	if err := config.DB.Delete(&models.Owner{}, id).Error; err != nil {
		return err
	}
	return nil
}

func GetOwnerByID(id string) (models.Owner, error) {
	var owner models.Owner
	if err := config.DB.Preload("User").Preload("User.Role").First(&owner, "id = ?", id).Error; err != nil {
		return owner, err
	}
	return owner, nil
}

func GetOwnerByName(name string) (models.Owner, error) {
	var owner models.Owner
	if err := config.DB.Preload("User").Preload("User.Role").Where("name = ?", name).First(&owner).Error; err != nil {
		return owner, err
	}
	return owner, nil
}

func GetAllOwners() ([]models.Owner, error) {
	var owners []models.Owner
	if err := config.DB.Preload("User").Preload("User.Role").Find(&owners).Error; err != nil {
		return nil, err
	}
	return owners, nil
}

func UpdateOwner(id string, updatedData models.Owner) (models.Owner, error) {
	var owner models.Owner
	if err := config.DB.First(&owner, "id = ?", id).Error; err != nil {
		return owner, err
	}

	owner.Name = updatedData.Name
	owner.Surname = updatedData.Surname
	owner.Phone = updatedData.Phone
	owner.Dni = updatedData.Dni
	owner.Cuit = updatedData.Cuit

	if err := config.DB.Save(&owner).Error; err != nil {
		return owner, err
	}

	if err := config.DB.Preload("User").Preload("User.Role").First(&owner, "id = ?", id).Error; err != nil {
		return owner, err
	}

	return owner, nil
}

func AssignUserToOwner(ownerID, userID uint) (models.Owner, error) {
	var owner models.Owner
	if err := config.DB.First(&owner, ownerID).Error; err != nil {
		return owner, err
	}

	owner.UserID = &userID
	if err := config.DB.Save(&owner).Error; err != nil {
		return owner, err
	}

	if err := config.DB.Preload("User").Preload("User.Role").First(&owner, ownerID).Error; err != nil {
		return owner, err
	}

	return owner, nil
}
