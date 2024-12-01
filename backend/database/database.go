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
	hashedPassword, err := utils.HashPassword("admin")
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
	hashedPassword, err := utils.HashPassword("user")
	if err != nil {
		log.Fatalf("Failed to hash password: %v", err)
	}

	regularUser := models.User{
		Name:     "Facundo",
		Email:    "user@example.com",
		Surname:  "Flores",
		Phone:    "3515510188",
		Dni:      "42694193",
		RoleID:   userRole.ID,
		Password: hashedPassword,
		IsActive: false,
	}

	if err := DB.FirstOrCreate(&regularUser, models.User{Email: regularUser.Email}).Error; err != nil {
		log.Fatalf("Failed to create regular user: %v", err)
	}
}

// SeedConsortiums seeds consortiums
func SeedConsortiums(DB *gorm.DB) {
	consortium := models.Consortium{
		Name:    "Edificio Prueba 42",
		Address: "Calle Falsa 123",
		Cuit:    "1098803053",
	}

	consortium2 := models.Consortium{
		Name:    "Consorcio Vacio",
		Address: "Calle Inexistencia 5312",
		Cuit:    "62624131556",
	}

	if err := DB.FirstOrCreate(&consortium, models.Consortium{Name: consortium.Name}).Error; err != nil {
		log.Fatalf("Failed to create consortium: %v", err)
	}

	if err := DB.FirstOrCreate(&consortium2, models.Consortium{Name: consortium.Name}).Error; err != nil {
		log.Fatalf("Failed to create consortium: %v", err)
	}

}

// SeedUnits seeds units and their owners/roomers
func SeedUnits(DB *gorm.DB) {
	var consortium models.Consortium
	if err := DB.First(&consortium, "name = ?", "Edificio Prueba 42").Error; err != nil {
		log.Fatalf("Edificio Prueba 42 not found: %v", err)
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
	}
}

// SeedCoefficients seeds coefficients
func SeedCoefficients(DB *gorm.DB) {
	coefficients := []models.Coefficient{
		{Name: "Coeficiente Distribuible", Distributable: true},
		{Name: "Coeficiente No Distribuible", Distributable: false},
		{Name: "Coeficiente Distribuible 2", Distributable: true},
		{Name: "Pago", Distributable: false},
	}

	for _, coefficient := range coefficients {
		DB.FirstOrCreate(&coefficient, models.Coefficient{Name: coefficient.Name})
	}
}

// SeedConcepts seeds concepts
func SeedConcepts(DB *gorm.DB) {
	var coefDistribuible, coefNoDistribuible, coefDistribuible2, pago models.Coefficient

	if err := DB.First(&coefDistribuible, "name = ?", "Coeficiente Distribuible").Error; err != nil {
		log.Fatalf("Coeficiente Distribuible not found: %v", err)
	}

	if err := DB.First(&coefNoDistribuible, "name = ?", "Coeficiente No Distribuible").Error; err != nil {
		log.Fatalf("Coeficiente No Distribuible not found: %v", err)
	}

	if err := DB.First(&coefDistribuible2, "name = ?", "Coeficiente Distribuible 2").Error; err != nil {
		log.Fatalf("Coeficiente Distribuible 2 not found: %v", err)
	}
	if err := DB.First(&pago, "name = ?", "Pago").Error; err != nil {
		log.Fatalf("Pago not found: %v", err)
	}

	concepts := []models.Concept{
		{Name: "Expensas comunes", Priority: 1, Origin: "Debe", Type: "Gasto comun", Description: "Expensas de edificio", CoefficientID: coefDistribuible.ID},
		{Name: "Servicio de Vigilancia", Priority: 2, Origin: "Debe", Type: "Gasto comun", Description: "Servicio de seguridad del edificio", CoefficientID: coefDistribuible.ID},
		{Name: "Imp.Inmobiliario Provincial", Priority: 3, Origin: "Debe", Type: "Gasto comun", Description: "Impuesto provincial al inmueble", CoefficientID: coefDistribuible2.ID},
		{Name: "Aguas Cordobesas", Priority: 3, Origin: "Debe", Type: "Gasto comun", Description: "Gastos de agua comunes del edificio", CoefficientID: coefDistribuible2.ID},
		{Name: "EPEC", Priority: 3, Origin: "Debe", Type: "Gasto comun", Description: "Gastos de luz comunes del edificio", CoefficientID: coefDistribuible2.ID},

		{Name: "Alquiler", Priority: 3, Origin: "Debe", Type: "Gasto comun", Description: "Alquiler de propiedad", CoefficientID: coefNoDistribuible.ID},
		{Name: "Luz", Priority: 3, Origin: "Debe", Type: "Gasto comun", Description: "Gastos de luz de propiedad", CoefficientID: coefNoDistribuible.ID},
		{Name: "Internet", Priority: 3, Origin: "Debe", Type: "Gasto comun", Description: "Servicio de conexion a internet", CoefficientID: coefNoDistribuible.ID},
		{Name: "Reparaciones", Priority: 1, Origin: "Debe", Type: "Gasto extraordinario", Description: "Cobro por averías dentro de propiedad", CoefficientID: coefNoDistribuible.ID},

		{Name: "Efectivo", Priority: 2, Origin: "Haber", Type: "Pago", Description: "Pago en efectivo a administrador", CoefficientID: pago.ID},
		{Name: "Descuento", Priority: 1, Origin: "Haber", Type: "Descuento", Description: "Descuento otorgado a expensa", CoefficientID: pago.ID},
		{Name: "Cheque", Priority: 3, Origin: "Haber", Type: "Pago", Description: "Cheque recibido por administrador", CoefficientID: pago.ID},
		{Name: "Transferencia", Priority: 2, Origin: "Haber", Type: "Pago", Description: "Transferencia realizada", CoefficientID: pago.ID},
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
	DB.First(&consortium, "name = ?", "Edificio Prueba 42")

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

// SeedConsortiumServices seeds consortium services
func SeedConsortiumServices(DB *gorm.DB) {
	var consortium models.Consortium
	DB.First(&consortium, "name = ?", "Edificio Prueba 42")

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
	DB.First(&consortium, "name = ?", "Edificio Prueba 42")

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

func SeedData(DB *gorm.DB) {
	SeedRoles(DB)
	SeedAdminUser(DB)
	SeedRegularUser(DB)
	SeedConsortiums(DB)
	SeedUnits(DB)
	SeedCoefficients(DB)
	SeedConcepts(DB)
	SeedUnitCoefficients(DB)
	SeedConsortiumServices(DB)
	SeedDocuments(DB)
	SeedNotifications(DB)
}
