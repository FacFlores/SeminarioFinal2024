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
		return models.User{}, errors.New("password must be at least 8 characters long, include at least one number, one lowercase letter, one uppercase letter, and one special character")
	}

	hashedPassword, err := utils.HashPassword(user.Password)
	if err != nil {
		return models.User{}, errors.New("failed to hash password")
	}
	user.Password = hashedPassword

	if err := config.DB.Create(&user).Error; err != nil {
		return models.User{}, err
	}
	return user, nil
}

func AuthenticateUser(email, password string) (string, error) {
	var user models.User
	if err := config.DB.Preload("Role").Where("email = ?", email).First(&user).Error; err != nil {
		return "", errors.New("invalid email or password")
	}

	if !utils.CheckPasswordHash(password, user.Password) {
		return "", errors.New("invalid email or password")
	}

	if !user.IsActive {
		return "", errors.New("user account is inactive")
	}

	token, err := middlewares.GenerateToken(user.ID)
	if err != nil {
		return "", err
	}

	return token, nil
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
