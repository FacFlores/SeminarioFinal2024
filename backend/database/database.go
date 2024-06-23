package database

import (
	"backend/models"
	"backend/utils"
	"log"
	"strconv"
	"time"

	"gorm.io/gorm"
)

// Seeds initial Roles
func SeedRoles(DB *gorm.DB) {
	roles := []models.Role{
		{Name: "Admin", Description: "Consortium Administrator"},
		{Name: "User", Description: "Property Owner or Roomer"},
	}

	for _, role := range roles {
		DB.FirstOrCreate(&role, models.Role{Name: role.Name})
	}
}

// SEED FOR TEST DATA //
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

func SeedRegularUser(DB *gorm.DB) {
	var userRole models.Role
	if err := DB.First(&userRole, "name = ?", "User").Error; err != nil {
		log.Fatalf("User role not found: %v", err)
	}
	hashedPassword, err := utils.HashPassword("userpassword")
	if err != nil {
		log.Fatalf("Failed to hash password: %v", err)
	}

	regularUser := models.User{
		Name:     "Regular",
		Email:    "user@example.com",
		Surname:  "User",
		Phone:    "0987654321",
		Dni:      "1111111111",
		RoleID:   userRole.ID,
		Password: hashedPassword,
		IsActive: true,
	}

	if err := DB.FirstOrCreate(&regularUser, models.User{Email: regularUser.Email}).Error; err != nil {
		log.Fatalf("Failed to create regular user: %v", err)
	}
}

func SeedConsortiums(DB *gorm.DB) {
	consortium := models.Consortium{
		Name:    "Test Consortium",
		Address: "123 Test Street",
		Cuit:    "12345678901",
	}

	if err := DB.FirstOrCreate(&consortium, models.Consortium{Name: consortium.Name}).Error; err != nil {
		log.Fatalf("Failed to create consortium: %v", err)
	}
}

func SeedUnits(DB *gorm.DB) {
	var consortium models.Consortium
	if err := DB.First(&consortium, "name = ?", "Test Consortium").Error; err != nil {
		log.Fatalf("Test Consortium not found: %v", err)
	}

	for i := 1; i <= 5; i++ {
		unit := models.Unit{
			Name:         "Unit " + strconv.Itoa(i),
			ConsortiumID: consortium.ID,
		}

		if err := DB.FirstOrCreate(&unit, models.Unit{Name: unit.Name}).Error; err != nil {
			log.Fatalf("Failed to create unit: %v", err)
		}

		unitLedger := models.UnitLedger{
			UnitID:  unit.ID,
			Balance: 0.0,
		}
		if err := DB.FirstOrCreate(&unitLedger, models.UnitLedger{UnitID: unitLedger.UnitID}).Error; err != nil {
			log.Fatalf("Failed to create unit ledger: %v", err)
		}
		userID := uint(2)
		owner := models.Owner{
			Name:    "Owner " + strconv.Itoa(i),
			Surname: "Surname " + strconv.Itoa(i),
			Phone:   "123456789" + strconv.Itoa(i),
			Dni:     "000000000" + strconv.Itoa(i),
			Cuit:    "1234567890" + strconv.Itoa(i),
			UserID:  &userID,
		}

		if err := DB.FirstOrCreate(&owner, models.Owner{Dni: owner.Dni}).Error; err != nil {
			log.Fatalf("Failed to create owner: %v", err)
		}

		roomer := models.Roomer{
			Name:    "Roomer " + strconv.Itoa(i),
			Surname: "Surname " + strconv.Itoa(i),
			Phone:   "123456789" + strconv.Itoa(i),
			Dni:     "000000000" + strconv.Itoa(i),
			Cuit:    "1234567890" + strconv.Itoa(i),
			UserID:  &userID,
		}

		if err := DB.FirstOrCreate(&roomer, models.Roomer{Dni: roomer.Dni}).Error; err != nil {
			log.Fatalf("Failed to create roomer: %v", err)
		}

		if err := DB.Model(&unit).Association("Owners").Append(&owner); err != nil {
			log.Fatalf("Failed to assign owner to unit: %v", err)
		}
		if err := DB.Model(&unit).Association("Roomers").Append(&roomer); err != nil {
			log.Fatalf("Failed to assign roomer to unit: %v", err)
		}
	}
}

func SeedCoefficients(DB *gorm.DB) {
	coefficients := []models.Coefficient{
		{Name: "Distributable Coefficient", Distributable: true},
		{Name: "Non-Distributable Coefficient", Distributable: false},
		{Name: "Distributable Coefficient 2", Distributable: true},
	}

	for _, coefficient := range coefficients {
		DB.FirstOrCreate(&coefficient, models.Coefficient{Name: coefficient.Name})
	}
}

func SeedConcepts(DB *gorm.DB) {
	var distributableCoefficient, nonDistributableCoefficient, distributableCoefficient2 models.Coefficient

	if err := DB.First(&distributableCoefficient, "name = ?", "Distributable Coefficient").Error; err != nil {
		log.Fatalf("Distributable Coefficient not found: %v", err)
	}

	if err := DB.First(&nonDistributableCoefficient, "name = ?", "Non-Distributable Coefficient").Error; err != nil {
		log.Fatalf("Non-Distributable Coefficient not found: %v", err)
	}

	if err := DB.First(&distributableCoefficient2, "name = ?", "Distributable Coefficient 2").Error; err != nil {
		log.Fatalf("Non-Distributable Coefficient not found: %v", err)
	}

	concepts := []models.Concept{
		{Name: "Debe Concept 1", Priority: 1, Origin: "Debe", Type: "Type1", Description: "Description 1", CoefficientID: distributableCoefficient.ID},
		{Name: "Debe Concept 2", Priority: 2, Origin: "Debe", Type: "Type2", Description: "Description 2", CoefficientID: distributableCoefficient2.ID},
		{Name: "Debe Concept 3", Priority: 3, Origin: "Debe", Type: "Type3", Description: "Description 3", CoefficientID: nonDistributableCoefficient.ID},
		{Name: "Haber Concept 1", Priority: 1, Origin: "Haber", Type: "Type1", Description: "Description 1", CoefficientID: distributableCoefficient.ID},
		{Name: "Haber Concept 2", Priority: 2, Origin: "Haber", Type: "Type2", Description: "Description 2", CoefficientID: nonDistributableCoefficient.ID},
		{Name: "Haber Concept 3", Priority: 4, Origin: "Haber", Type: "Type3", Description: "Description 3", CoefficientID: distributableCoefficient2.ID},
	}

	for _, concept := range concepts {
		DB.FirstOrCreate(&concept, models.Concept{Name: concept.Name})
	}
}

func SeedUnitCoefficients(DB *gorm.DB) {
	var distributableCoefficient, distributableCoefficient2 models.Coefficient

	if err := DB.First(&distributableCoefficient, "name = ?", "Distributable Coefficient").Error; err != nil {
		log.Fatalf("Distributable Coefficient not found: %v", err)
	}

	if err := DB.First(&distributableCoefficient2, "name = ?", "Distributable Coefficient 2").Error; err != nil {
		log.Fatalf("Non-Distributable Coefficient not found: %v", err)
	}

	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Test Consortium")

	var units []models.Unit
	DB.Where("consortium_id = ?", consortium.ID).Find(&units)

	for _, unit := range units {
		unitCoefficient := models.UnitCoefficient{
			UnitID:        unit.ID,
			CoefficientID: distributableCoefficient.ID,
			Percentage:    20.0,
		}
		if err := DB.FirstOrCreate(&unitCoefficient, models.UnitCoefficient{UnitID: unit.ID, CoefficientID: distributableCoefficient.ID}).Error; err != nil {
			log.Fatalf("Failed to create unit coefficient: %v", err)
		}
	}

	for _, unit := range units {
		unitCoefficient := models.UnitCoefficient{
			UnitID:        unit.ID,
			CoefficientID: distributableCoefficient2.ID,
			Percentage:    20.0,
		}
		if err := DB.FirstOrCreate(&unitCoefficient, models.UnitCoefficient{UnitID: unit.ID, CoefficientID: distributableCoefficient2.ID}).Error; err != nil {
			log.Fatalf("Failed to create unit coefficient: %v", err)
		}
	}

}

func SeedConsortiumExpenses(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Test Consortium")

	expenses := []models.ConsortiumExpense{
		{Description: "Test Expense 1", BillNumber: 1, Amount: 1000.0, ConceptID: 1, ExpensePeriod: time.Now(), Distributed: false, ConsortiumID: consortium.ID},
		{Description: "Test Expense 2", BillNumber: 2, Amount: 2000.0, ConceptID: 2, ExpensePeriod: time.Now(), Distributed: false, ConsortiumID: consortium.ID},
	}

	for _, expense := range expenses {
		DB.FirstOrCreate(&expense, models.ConsortiumExpense{BillNumber: expense.BillNumber})
	}
}

func SeedUnitExpenses(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Test Consortium")

	var unit models.Unit
	DB.First(&unit, "consortium_id = ?", consortium.ID)

	expenses := []models.UnitExpense{
		{Description: "Test Unit Expense 1", BillNumber: 1, Amount: 500.0, LeftToPay: 500.0, ConceptID: 1, ExpensePeriod: time.Now(), LiquidatePeriod: time.Now(), Liquidated: false, Paid: false, UnitID: unit.ID},
		{Description: "Test Unit Expense 2", BillNumber: 2, Amount: 1500.0, LeftToPay: 1500.0, ConceptID: 2, ExpensePeriod: time.Now(), LiquidatePeriod: time.Now(), Liquidated: false, Paid: false, UnitID: unit.ID},
	}

	for _, expense := range expenses {
		DB.FirstOrCreate(&expense, models.UnitExpense{BillNumber: expense.BillNumber})
	}
}

func SeedData(DB *gorm.DB) {
	SeedRoles(DB)
	SeedAdminUser(DB)
	SeedRegularUser(DB)
	SeedConsortiums(DB)
	SeedUnits(DB)
	SeedCoefficients(DB)
	SeedConcepts(DB)
	SeedUnitCoefficients(DB)
	SeedConsortiumExpenses(DB)
	SeedUnitExpenses(DB)

}
