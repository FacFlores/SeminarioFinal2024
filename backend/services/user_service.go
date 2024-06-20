package services

import (
	"backend/config"
	"backend/middlewares"
	"backend/models"
	"backend/utils"
	"errors"
)

// GetAllUsers retrieves all users from the database
func GetAllUsers() ([]models.User, error) {
	var users []models.User
	if err := config.DB.Preload("Role").Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

// CreateUser creates a new user in the database
func CreateUser(user models.User) (models.User, error) {
	// Validate the password
	if !utils.IsValidPassword(user.Password) {
		return models.User{}, errors.New("password must be at least 8 characters long, include at least one number, one lowercase letter, one uppercase letter, and one special character")
	}

	// Hash the password
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

// AuthenticateUser authenticates a user and returns a JWT token
func AuthenticateUser(email, password string) (string, error) {
	var user models.User
	if err := config.DB.Preload("Role").Where("email = ?", email).First(&user).Error; err != nil {
		return "", errors.New("invalid email or password")
	}

	// Check the password
	if !utils.CheckPasswordHash(password, user.Password) {
		return "", errors.New("invalid email or password")
	}

	// Generate JWT token
	token, err := middlewares.GenerateToken(user.ID)
	if err != nil {
		return "", err
	}

	return token, nil
}
