package config

import (
	"backend/database"
	"backend/models"
	"backend/utils"
	"fmt"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	utils.LoadEnv()
	dbHost := utils.GetEnv("DB_HOST", "localhost")
	dbUser := utils.GetEnv("DB_USER", "postgres")
	dbName := utils.GetEnv("DB_NAME", "SeminarioFF")
	dbSSLMode := utils.GetEnv("DB_SSLMODE", "disable")
	dbPassword := utils.GetEnv("DB_PASSWORD", "postgres")

	dsn := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=%s password=%s", dbHost, dbUser, dbName, dbSSLMode, dbPassword)

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database: ", err)
	}

	fmt.Println("Database connected")
	DB.AutoMigrate(&models.User{}, &models.Role{}, &models.Owner{}, &models.Roomer{}, &models.Consortium{}, &models.Unit{}, &models.Coefficient{}, &models.Concept{}, &models.UnitCoefficient{}, &models.UnitExpense{}, &models.ConsortiumExpense{}, &models.UnitLedger{}, &models.Transaction{}, &models.Payment{}, &models.ConsortiumService{}, &models.Notification{}, &models.Document{}, &models.Service{}, &models.Space{}, &models.Reservation{})
	database.SeedData(DB)

}
