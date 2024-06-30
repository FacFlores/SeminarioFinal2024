package database

import (
	"backend/models"
	"backend/utils"
	"log"
	"strconv"
	"time"

	"gorm.io/gorm"
)

// SeedRoles seeds initial roles
func SeedRoles(DB *gorm.DB) {
	roles := []models.Role{
		{Name: "Admin", Description: "Administrador del Consorcio"},
		{Name: "User", Description: "Propietario o Inquilino"},
	}

	for _, role := range roles {
		DB.FirstOrCreate(&role, models.Role{Name: role.Name})
	}
}

// / TEST DATA :D ///
// SeedAdminUser seeds an admin user
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
		Name:     "Administrador",
		Email:    "admin@example.com",
		Surname:  "Principal",
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

// SeedRegularUser seeds a regular user
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
		Name:     "Usuario",
		Email:    "user@example.com",
		Surname:  "Regular",
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

// SeedConsortiums seeds consortiums
func SeedConsortiums(DB *gorm.DB) {
	consortium := models.Consortium{
		Name:    "Consorcio de Prueba",
		Address: "Calle Falsa 123",
		Cuit:    "12345678901",
	}

	if err := DB.FirstOrCreate(&consortium, models.Consortium{Name: consortium.Name}).Error; err != nil {
		log.Fatalf("Failed to create consortium: %v", err)
	}
}

// SeedUnits seeds units and their owners/roomers
func SeedUnits(DB *gorm.DB) {
	var consortium models.Consortium
	if err := DB.First(&consortium, "name = ?", "Consorcio de Prueba").Error; err != nil {
		log.Fatalf("Consorcio de Prueba not found: %v", err)
	}

	for i := 1; i <= 5; i++ {
		unit := models.Unit{
			Name:         "Unidad " + strconv.Itoa(i),
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
			Name:    "Propietario " + strconv.Itoa(i),
			Surname: "Apellido " + strconv.Itoa(i),
			Phone:   "123456789" + strconv.Itoa(i),
			Dni:     "000000000" + strconv.Itoa(i),
			Cuit:    "1234567890" + strconv.Itoa(i),
			UserID:  &userID,
		}

		if err := DB.FirstOrCreate(&owner, models.Owner{Dni: owner.Dni}).Error; err != nil {
			log.Fatalf("Failed to create owner: %v", err)
		}

		roomer := models.Roomer{
			Name:    "Inquilino " + strconv.Itoa(i),
			Surname: "Apellido " + strconv.Itoa(i),
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

// SeedCoefficients seeds coefficients
func SeedCoefficients(DB *gorm.DB) {
	coefficients := []models.Coefficient{
		{Name: "Coeficiente Distribuible", Distributable: true},
		{Name: "Coeficiente No Distribuible", Distributable: false},
		{Name: "Coeficiente Distribuible 2", Distributable: true},
	}

	for _, coefficient := range coefficients {
		DB.FirstOrCreate(&coefficient, models.Coefficient{Name: coefficient.Name})
	}
}

// SeedConcepts seeds concepts
func SeedConcepts(DB *gorm.DB) {
	var coefDistribuible, coefNoDistribuible, coefDistribuible2 models.Coefficient

	if err := DB.First(&coefDistribuible, "name = ?", "Coeficiente Distribuible").Error; err != nil {
		log.Fatalf("Coeficiente Distribuible not found: %v", err)
	}

	if err := DB.First(&coefNoDistribuible, "name = ?", "Coeficiente No Distribuible").Error; err != nil {
		log.Fatalf("Coeficiente No Distribuible not found: %v", err)
	}

	if err := DB.First(&coefDistribuible2, "name = ?", "Coeficiente Distribuible 2").Error; err != nil {
		log.Fatalf("Coeficiente Distribuible 2 not found: %v", err)
	}

	concepts := []models.Concept{
		{Name: "Concepto Debe 1", Priority: 1, Origin: "Debe", Type: "Tipo1", Description: "Descripción 1", CoefficientID: coefDistribuible.ID},
		{Name: "Concepto Debe 2", Priority: 2, Origin: "Debe", Type: "Tipo2", Description: "Descripción 2", CoefficientID: coefDistribuible2.ID},
		{Name: "Concepto Debe 3", Priority: 3, Origin: "Debe", Type: "Tipo3", Description: "Descripción 3", CoefficientID: coefNoDistribuible.ID},
		{Name: "Concepto Haber 1", Priority: 1, Origin: "Haber", Type: "Tipo1", Description: "Descripción 1", CoefficientID: coefDistribuible.ID},
		{Name: "Concepto Haber 2", Priority: 2, Origin: "Haber", Type: "Tipo2", Description: "Descripción 2", CoefficientID: coefNoDistribuible.ID},
		{Name: "Concepto Haber 3", Priority: 4, Origin: "Haber", Type: "Tipo3", Description: "Descripción 3", CoefficientID: coefDistribuible2.ID},
	}

	for _, concept := range concepts {
		DB.FirstOrCreate(&concept, models.Concept{Name: concept.Name})
	}
}

// SeedUnitCoefficients seeds unit coefficients
func SeedUnitCoefficients(DB *gorm.DB) {
	var coefDistribuible, coefDistribuible2 models.Coefficient

	if err := DB.First(&coefDistribuible, "name = ?", "Coeficiente Distribuible").Error; err != nil {
		log.Fatalf("Coeficiente Distribuible not found: %v", err)
	}

	if err := DB.First(&coefDistribuible2, "name = ?", "Coeficiente Distribuible 2").Error; err != nil {
		log.Fatalf("Coeficiente Distribuible 2 not found: %v", err)
	}

	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Consorcio de Prueba")

	var units []models.Unit
	DB.Where("consortium_id = ?", consortium.ID).Find(&units)

	for _, unit := range units {
		unitCoefficient := models.UnitCoefficient{
			UnitID:        unit.ID,
			CoefficientID: coefDistribuible.ID,
			Percentage:    20.0,
		}
		if err := DB.FirstOrCreate(&unitCoefficient, models.UnitCoefficient{UnitID: unit.ID, CoefficientID: coefDistribuible.ID}).Error; err != nil {
			log.Fatalf("Failed to create unit coefficient: %v", err)
		}
	}

	for _, unit := range units {
		unitCoefficient := models.UnitCoefficient{
			UnitID:        unit.ID,
			CoefficientID: coefDistribuible2.ID,
			Percentage:    20.0,
		}
		if err := DB.FirstOrCreate(&unitCoefficient, models.UnitCoefficient{UnitID: unit.ID, CoefficientID: coefDistribuible2.ID}).Error; err != nil {
			log.Fatalf("Failed to create unit coefficient: %v", err)
		}
	}
}

// SeedConsortiumExpenses seeds consortium expenses
func SeedConsortiumExpenses(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Consorcio de Prueba")

	expenses := []models.ConsortiumExpense{
		{Description: "Gasto de Consorcio 1", BillNumber: 1, Amount: 1000.0, ConceptID: 1, ExpensePeriod: time.Now(), LiquidatePeriod: time.Now(), Distributed: false, ConsortiumID: consortium.ID},
		{Description: "Gasto de Consorcio 2", BillNumber: 2, Amount: 2000.0, ConceptID: 2, ExpensePeriod: time.Now(), LiquidatePeriod: time.Now(), Distributed: false, ConsortiumID: consortium.ID},
	}

	for _, expense := range expenses {
		DB.FirstOrCreate(&expense, models.ConsortiumExpense{BillNumber: expense.BillNumber})
	}
}

// SeedUnitExpenses seeds unit expenses
func SeedUnitExpenses(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Consorcio de Prueba")

	var unit models.Unit
	DB.First(&unit, "consortium_id = ?", consortium.ID)

	expenses := []models.UnitExpense{
		{Description: "Gasto de Unidad 1", BillNumber: 1, Amount: 500.0, LeftToPay: 500.0, ConceptID: 1, ExpensePeriod: time.Now(), LiquidatePeriod: time.Now(), Liquidated: false, Paid: false, UnitID: unit.ID},
		{Description: "Gasto de Unidad 2", BillNumber: 2, Amount: 1500.0, LeftToPay: 1500.0, ConceptID: 2, ExpensePeriod: time.Now(), LiquidatePeriod: time.Now(), Liquidated: false, Paid: false, UnitID: unit.ID},
	}

	for _, expense := range expenses {
		DB.FirstOrCreate(&expense, models.UnitExpense{BillNumber: expense.BillNumber})
	}
}

// SeedConsortiumServices seeds consortium services
func SeedConsortiumServices(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Consorcio de Prueba")

	services := []models.ConsortiumService{
		{
			Name:            "Mantenimiento de Ascensor",
			Description:     "Revisión y mantenimiento mensual del ascensor.",
			ScheduledDate:   time.Now().AddDate(0, 1, 0),
			NextMaintenance: time.Now().AddDate(0, 2, 0),
			ExpiryDate:      time.Now().AddDate(1, 0, 0),
			Status:          "Programado",
			ConsortiumID:    consortium.ID,
		},
		{
			Name:            "Limpieza General",
			Description:     "Limpieza profunda de áreas comunes.",
			ScheduledDate:   time.Now().AddDate(0, 0, 7),
			NextMaintenance: time.Now().AddDate(0, 1, 7),
			ExpiryDate:      time.Now().AddDate(1, 0, 0),
			Status:          "Programado",
			ConsortiumID:    consortium.ID,
		},
	}

	for _, service := range services {
		DB.FirstOrCreate(&service, models.ConsortiumService{Name: service.Name, ConsortiumID: consortium.ID})
	}
}

// SeedDocuments seeds documents
func SeedDocuments(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Consorcio de Prueba")

	var unit models.Unit
	DB.First(&unit, "consortium_id = ?", consortium.ID)

	documents := []models.Document{
		{
			Name:         "Reglamento Interno",
			ContentType:  "application/pdf",
			Content:      []byte("Contenido del Reglamento Interno"),
			Visibility:   models.ConsortiumVisibility,
			ConsortiumID: &consortium.ID,
		},
		{
			Name:        "Manual de Uso del Ascensor",
			ContentType: "application/pdf",
			Content:     []byte("Contenido del Manual de Uso del Ascensor"),
			Visibility:  models.UnitVisibility,
			UnitID:      &unit.ID,
		},
	}

	for _, document := range documents {
		DB.FirstOrCreate(&document, models.Document{Name: document.Name})
	}
}

// SeedNotifications seeds notifications
func SeedNotifications(DB *gorm.DB) {
	var adminUser models.User
	DB.First(&adminUser, "email = ?", "admin@example.com")

	notifications := []models.Notification{
		{
			UserID:     adminUser.ID,
			Message:    "Nueva actualización del reglamento interno disponible.",
			IsRead:     false,
			TargetRole: "admin",
		},
		{
			UserID:     adminUser.ID,
			Message:    "Servicio de mantenimiento del ascensor programado para el próximo mes.",
			IsRead:     false,
			TargetRole: "consortium",
		},
	}

	for _, notification := range notifications {
		DB.FirstOrCreate(&notification, models.Notification{Message: notification.Message})
	}
}

// SeedPayments seeds payments
func SeedPayments(DB *gorm.DB) {
	var unitExpense models.UnitExpense
	DB.First(&unitExpense, "bill_number = ?", 1)

	var transaction models.Transaction
	DB.First(&transaction, "unit_ledger_id = ?", unitExpense.UnitID)

	payments := []models.Payment{
		{
			Amount:        100.0,
			Description:   "Pago parcial del Gasto de Unidad 1",
			UnitExpenseID: &unitExpense.ID,
			TransactionID: transaction.ID,
		},
		{
			Amount:        200.0,
			Description:   "Pago parcial del Gasto de Unidad 2",
			UnitExpenseID: &unitExpense.ID,
			TransactionID: transaction.ID,
		},
	}

	for _, payment := range payments {
		DB.FirstOrCreate(&payment, models.Payment{Description: payment.Description})
	}
}

// SeedTransactions seeds transactions
func SeedTransactions(DB *gorm.DB) {
	var unitLedger models.UnitLedger
	DB.First(&unitLedger, "unit_id = ?", 1)

	var concept models.Concept
	DB.First(&concept, "name = ?", "Concepto Debe 1")

	transactions := []models.Transaction{
		{
			UnitLedgerID: unitLedger.ID,
			Amount:       100.0,
			Description:  "Transacción inicial",
			Date:         time.Now(),
			ConceptID:    concept.ID,
		},
	}

	for _, transaction := range transactions {
		DB.FirstOrCreate(&transaction, models.Transaction{Description: transaction.Description})
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
	SeedConsortiumServices(DB)
	SeedDocuments(DB)
	SeedNotifications(DB)
	SeedPayments(DB)
	SeedTransactions(DB)
}
