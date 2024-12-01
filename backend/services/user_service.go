package services

import (
	"backend/config"
	"backend/middlewares"
	"backend/models"
	"backend/utils"
	"errors"
)

func GetAllUsers() ([]models.User, error) {
	var users []models.User
	if err := config.DB.Preload("Role").Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

func GetAllAdmins() ([]models.User, error) {
	var admins []models.User
	if err := config.DB.Preload("Role").Where("name = ?", "Admin").Find(&admins).Error; err != nil {
		return nil, err
	}
	return admins, nil
}

func GetActiveUsers() ([]models.User, error) {
	var users []models.User
	if err := config.DB.Preload("Role").Where("is_active = ?", true).Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

func GetDisabledUsers() ([]models.User, error) {
	var users []models.User
	if err := config.DB.Preload("Role").Where("is_active = ?", false).Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

func CreateUser(user models.User) (models.User, error) {
	if !utils.IsValidPassword(user.Password) {
		return models.User{}, errors.New("la contraseña debe tener al menos 8 caracteres e incluir al menos un número, una letra minúscula, una letra mayúscula y un carácter especial")
	}

	hashedPassword, err := utils.HashPassword(user.Password)
	if err != nil {
		return models.User{}, errors.New("error al hashear contraseña")
	}
	user.Password = hashedPassword

	if err := config.DB.Create(&user).Error; err != nil {
		return models.User{}, err
	}
	return user, nil
}

func AuthenticateUser(email, password string) (string, models.User, error) {
	var user models.User
	if err := config.DB.Preload("Role").Where("email = ?", email).First(&user).Error; err != nil {
		return "", user, errors.New("email o contraseña invalidos")
	}

	if !utils.CheckPasswordHash(password, user.Password) {
		return "", user, errors.New("email o contraseña invalidos")
	}

	if !user.IsActive {
		return "", user, errors.New("su cuenta esta inactiva, contacte al adminstrador para gestionar su acceso")
	}

	token, err := middlewares.GenerateToken(user.ID)
	if err != nil {
		return "", user, err
	}

	return token, user, nil
}

func ToggleUserActiveStatus(user models.User) (models.User, error) {
	user.IsActive = !user.IsActive
	if err := config.DB.Save(&user).Error; err != nil {
		return user, err
	}
	return user, nil
}

func GetUserByID(id string) (models.User, error) {
	var user models.User
	if err := config.DB.Preload("Role").First(&user, "id = ?", id).Error; err != nil {
		return user, err
	}
	return user, nil
}

func DeleteUser(id string) error {
	if err := config.DB.Delete(&models.User{}, id).Error; err != nil {
		return err
	}
	return nil
}

func UpdateUser(id uint, updateUser models.User) (models.User, error) {
	var existingUser models.User
	if err := config.DB.First(&existingUser, id).Error; err != nil {
		return existingUser, err
	}

	existingUser.Name = updateUser.Name
	existingUser.Email = updateUser.Email
	existingUser.Surname = updateUser.Surname
	existingUser.Phone = updateUser.Phone
	existingUser.Dni = updateUser.Dni
	existingUser.ProfilePicture = updateUser.ProfilePicture

	if err := config.DB.Save(&existingUser).Error; err != nil {
		return existingUser, err
	}

	return existingUser, nil
}

func GetUnitsByUser(userID uint) ([]models.Unit, error) {
	var ownerUnitIDs []uint
	var roomerUnitIDs []uint
	if err := config.DB.Table("units").
		Select("units.id").
		Joins("JOIN unit_owners ON units.id = unit_owners.unit_id").
		Joins("JOIN owners ON owners.id = unit_owners.owner_id").
		Where("owners.user_id = ?", userID).
		Where("units.deleted_at IS NULL").
		Pluck("units.id", &ownerUnitIDs).Error; err != nil {
		return nil, err
	}
	if err := config.DB.Table("units").
		Select("units.id").
		Joins("JOIN unit_roomers ON units.id = unit_roomers.unit_id").
		Joins("JOIN roomers ON roomers.id = unit_roomers.roomer_id").
		Where("roomers.user_id = ?", userID).
		Where("units.deleted_at IS NULL").
		Pluck("units.id", &roomerUnitIDs).Error; err != nil {
		return nil, err
	}
	unitIDMap := make(map[uint]bool)
	for _, id := range ownerUnitIDs {
		unitIDMap[id] = true
	}
	for _, id := range roomerUnitIDs {
		unitIDMap[id] = true
	}
	uniqueUnitIDs := make([]uint, 0, len(unitIDMap))
	for id := range unitIDMap {
		uniqueUnitIDs = append(uniqueUnitIDs, id)
	}

	var units []models.Unit
	if err := config.DB.Preload("Owners").
		Preload("Roomers").
		Preload("Consortium").
		Where("id IN ?", uniqueUnitIDs).
		Where("units.deleted_at IS NULL").
		Find(&units).Error; err != nil {
		return nil, err
	}

	return units, nil
}
