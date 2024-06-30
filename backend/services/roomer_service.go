package services

import (
	"backend/config"
	"backend/models"
)

func CreateRoomer(roomer models.Roomer) (models.Roomer, error) {
	if err := config.DB.Create(&roomer).Error; err != nil {
		return roomer, err
	}
	return roomer, nil
}

func DeleteRoomer(id string) error {
	if err := config.DB.Delete(&models.Roomer{}, id).Error; err != nil {
		return err
	}
	return nil
}

func GetRoomersNotLinkedToUser() ([]models.Roomer, error) {
	var roomers []models.Roomer
	err := config.DB.Where("user_id IS NULL").Find(&roomers).Error
	if err != nil {
		return nil, err
	}
	return roomers, nil
}

func GetRoomersByUserID(userID uint) ([]models.Roomer, error) {
	var roomers []models.Roomer
	err := config.DB.Where("user_id = ?", userID).Find(&roomers).Error
	if err != nil {
		return nil, err
	}
	return roomers, nil
}

func RemoveUserFromRoomer(roomerID uint) (models.Roomer, error) {
	var roomer models.Roomer
	err := config.DB.First(&roomer, roomerID).Error
	if err != nil {
		return roomer, err
	}

	roomer.UserID = nil
	err = config.DB.Save(&roomer).Error
	if err != nil {
		return roomer, err
	}

	return roomer, nil
}

func GetRoomerByID(id string) (models.Roomer, error) {
	var roomer models.Roomer
	if err := config.DB.Preload("User").Preload("User.Role").First(&roomer, "id = ?", id).Error; err != nil {
		return roomer, err
	}
	return roomer, nil
}

func GetRoomerByName(name string) (models.Roomer, error) {
	var roomer models.Roomer
	if err := config.DB.Preload("User").Preload("User.Role").Where("name = ?", name).First(&roomer).Error; err != nil {
		return roomer, err
	}
	return roomer, nil
}

func GetAllRoomers() ([]models.Roomer, error) {
	var roomers []models.Roomer
	if err := config.DB.Preload("User").Preload("User.Role").Find(&roomers).Error; err != nil {
		return nil, err
	}
	return roomers, nil
}

func UpdateRoomer(id string, updatedData models.Roomer) (models.Roomer, error) {
	var roomer models.Roomer
	if err := config.DB.First(&roomer, "id = ?", id).Error; err != nil {
		return roomer, err
	}

	roomer.Name = updatedData.Name
	roomer.Surname = updatedData.Surname
	roomer.Phone = updatedData.Phone
	roomer.Dni = updatedData.Dni
	roomer.Cuit = updatedData.Cuit

	if err := config.DB.Save(&roomer).Error; err != nil {
		return roomer, err
	}

	if err := config.DB.Preload("User").Preload("User.Role").First(&roomer, "id = ?", id).Error; err != nil {
		return roomer, err
	}

	return roomer, nil
}

func AssignUserToRoomer(roomerID, userID uint) (models.Roomer, error) {
	var roomer models.Roomer
	if err := config.DB.First(&roomer, roomerID).Error; err != nil {
		return roomer, err
	}

	roomer.UserID = &userID
	if err := config.DB.Save(&roomer).Error; err != nil {
		return roomer, err
	}

	if err := config.DB.Preload("User").Preload("User.Role").First(&roomer, roomerID).Error; err != nil {
		return roomer, err
	}

	return roomer, nil
}
