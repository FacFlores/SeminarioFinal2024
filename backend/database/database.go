package database

import (
	"backend/models"
	"backend/utils"
	"log"

	"gorm.io/gorm"
)

// Seeds initial Roles
func SeedRoles(DB *gorm.DB) {
	roles := []models.Role{
		{Name: "Admin", Description: "Consortium Administrator"},
		{Name: "Owner", Description: "Property Owner"},
		{Name: "Roomer", Description: "Property Roomer"},
	}

	for _, role := range roles {
		DB.FirstOrCreate(&role, models.Role{Name: role.Name})
	}
}

// SeedAdminUser seeds an initial admin user, this is for Demo Purposes
func SeedAdminUser(DB *gorm.DB) {
	var adminRole models.Role
	if err := DB.First(&adminRole, "name = ?", "Admin").Error; err != nil {
		log.Fatalf("Admin role not found: %v", err)
	}
	hashedPassword, err := utils.HashPassword("adminpassword")
	if err != nil {
		log.Fatalf("Failed to hash password: %v", err)
	}

	adminUser := models.User{
		Name:     "Admin",
		Email:    "admin@example.com",
		Surname:  "User",
		Phone:    "1234567890",
		Dni:      "0000000000",
		RoleID:   adminRole.ID,
		Password: hashedPassword,
		IsActive: true,
	}

	if err := DB.FirstOrCreate(&adminUser, models.User{Email: adminUser.Email}).Error; err != nil {
		log.Fatalf("Failed to create admin user: %v", err)
	}
}

func SeedData(DB *gorm.DB) {
	SeedRoles(DB)
	SeedAdminUser(DB)
}
