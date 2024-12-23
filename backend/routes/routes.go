package routes

import (
	"backend/controllers"
	"backend/middlewares"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	// User routes
	users := router.Group("/users")
	{
		users.GET("", middlewares.AuthMiddleware(), middlewares.UserMiddleware(), controllers.FindUsers)
		users.GET("/active", middlewares.AuthMiddleware(), controllers.FindActiveUsers)
		users.GET("/inactive", middlewares.AuthMiddleware(), controllers.FindInactiveUsers)
		users.POST("/register", controllers.CreateUser)
		users.POST("/login", controllers.Login)
		users.GET("/:id", middlewares.AuthMiddleware(), controllers.GetUserByID)
		users.PUT("/:id", middlewares.AuthMiddleware(), controllers.UpdateUser)
		users.GET("/units/:userID", middlewares.AuthMiddleware(), controllers.GetUnitsByUser)

	}
	// Admin routes

	admin := router.Group("/admin")
	{
		admin.POST("/register", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateAdmin)
		admin.PUT("/toggle-user-status/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.ToggleUserActiveStatus)
		admin.DELETE("users/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteUser)
		admin.GET("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.GetAdminUsers)

	}

	// Roles routes
	roles := router.Group("/roles")
	{
		roles.GET("", controllers.GetAllRoles)
		roles.POST("/name", middlewares.AuthMiddleware(), controllers.GetRoleByName)
		roles.GET("/:id", middlewares.AuthMiddleware(), controllers.GetRoleByID)
		roles.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateRole)
		roles.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteRole)
	}

	// Owner routes
	owners := router.Group("/owners")
	{
		owners.GET("", middlewares.AuthMiddleware(), controllers.GetAllOwners)
		owners.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateOwner)
		owners.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateOwner)
		owners.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteOwner)
		owners.PUT("/assign-user/:owner_id/:user_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AssignUserToOwner) // PUT /owners/assign-user/:owner_id/:user_id
		owners.GET("/:id", middlewares.AuthMiddleware(), controllers.GetOwnerByID)
		owners.POST("/name", middlewares.AuthMiddleware(), controllers.GetOwnerByName)

		owners.PUT("/remove-user/:owner_id/:user_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.RemoveUserFromOwner)

		owners.GET("/not-assigned", middlewares.AuthMiddleware(), controllers.GetOwnersNotLinkedToUser)
		owners.GET("/linked/:user_id", middlewares.AuthMiddleware(), controllers.GetOwnersByUserID)

	}

	// Roomer routes
	roomers := router.Group("/roomers")
	{
		roomers.GET("", middlewares.AuthMiddleware(), controllers.GetAllRoomers)
		roomers.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateRoomer)
		roomers.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateRoomer)
		roomers.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteRoomer)
		roomers.PUT("/assign-user/:roomer_id/:user_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AssignUserToRoomer) // PUT /roomers/assign-user/:roomer_id/:user_id
		roomers.GET("/:id", middlewares.AuthMiddleware(), controllers.GetRoomerByID)
		roomers.POST("/name", middlewares.AuthMiddleware(), controllers.GetRoomerByName)
		roomers.PUT("/remove-user/:roomer_id/:user_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.RemoveUserFromRoomer)

		roomers.GET("/not-assigned", middlewares.AuthMiddleware(), controllers.GetRoomersNotLinkedToUser)
		roomers.GET("/linked/:user_id", middlewares.AuthMiddleware(), controllers.GetRoomersByUserID)

	}

	// Consortium routes
	consortiums := router.Group("/consortiums")
	{
		consortiums.GET("", controllers.GetAllConsortiums)
		consortiums.GET("/:id", controllers.GetConsortiumByID)
		consortiums.POST("/name", controllers.GetConsortiumByName)
		consortiums.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateConsortium)
		consortiums.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateConsortium)
		consortiums.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteConsortium)
		consortiums.GET("/unit/:unit_id", middlewares.AuthMiddleware(), controllers.GetConsortiumByUnit)
		consortiums.POST("/units-with-coefficients", controllers.GetUnitsWithCoefficients)

	}

	// Unit routes
	units := router.Group("/units")
	{
		units.GET("", controllers.GetAllUnits)
		units.GET("/:id", controllers.GetUnitByID)
		units.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateUnit)
		units.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateUnit)
		units.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteUnit)
		units.PUT("/assign-owner/:unit_id/:owner_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AssignOwnerToUnit)      // PUT /units/assign-owner/:unit_id/:owner_id
		units.PUT("/assign-roomer/:unit_id/:roomer_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AssignRoomerToUnit)   // PUT /units/assign-roomer/:unit_id/:roomer_id
		units.PUT("/remove-owner/:unit_id/:owner_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.RemoveOwnerFromUnit)    // PUT /units/remove-owner/:unit_id/:owner_id
		units.PUT("/remove-roomer/:unit_id/:roomer_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.RemoveRoomerFromUnit) // PUT /units/remove-roomer/:unit_id/:roomer_id
		units.POST("/name", middlewares.AuthMiddleware(), controllers.GetUnitByName)
		units.GET("/consortium/:consortium_id", middlewares.AuthMiddleware(), controllers.GetUnitsByConsortium)
		units.GET("/:id/owners", middlewares.AuthMiddleware(), controllers.GetOwnersByUnitID)
		units.GET("/:id/roomers", middlewares.AuthMiddleware(), controllers.GetRoomersByUnitID)

	}

	// Coefficient routes
	coefficients := router.Group("/coefficients")
	{
		coefficients.GET("", controllers.GetAllCoefficients)
		coefficients.GET("/:id", controllers.GetCoefficientByID)
		coefficients.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateCoefficient)
		coefficients.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateCoefficient)
		coefficients.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteCoefficient)
	}

	// Concept routes
	concepts := router.Group("/concepts")
	{
		concepts.GET("", controllers.GetAllConcepts)
		concepts.GET("/:id", controllers.GetConceptByID)
		concepts.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateConcept)
		concepts.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateConcept)
		concepts.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteConcept)
	}

	// Unit Coefficient routes
	unitCoefficients := router.Group("/unit-coefficients")
	{
		unitCoefficients.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateUnitCoefficients)
	}

	// Ledger routes
	ledger := router.Group("/ledger")
	{
		ledger.POST("/transaction", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.RecordTransaction)
		ledger.GET("/balance/:unit_id", middlewares.AuthMiddleware(), controllers.GetUnitBalance)
		ledger.GET("/transactions/:unit_id", middlewares.AuthMiddleware(), controllers.GetUnitTransactions)
		ledger.DELETE("/soft-delete/:unit_id", middlewares.AuthMiddleware(), controllers.SoftDeleteUnitLedgerByUnitID)

	}

	// ConsortiumExpense routes
	consortiumExpenses := router.Group("/consortium-expenses")
	{
		consortiumExpenses.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateConsortiumExpense)
		consortiumExpenses.GET("/:id", middlewares.AuthMiddleware(), controllers.GetConsortiumExpenseByID)
		consortiumExpenses.GET("", middlewares.AuthMiddleware(), controllers.GetAllConsortiumExpenses)
		consortiumExpenses.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateConsortiumExpense)
		consortiumExpenses.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteConsortiumExpense)
		consortiumExpenses.POST("/distribute/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DistributeConsortiumExpense)
		consortiumExpenses.GET("/distributed/:consortium_id", middlewares.AuthMiddleware(), controllers.GetDistributedConsortiumExpensesByConsortium)
		consortiumExpenses.GET("/non-distributed/:consortium_id", middlewares.AuthMiddleware(), controllers.GetNonDistributedConsortiumExpensesByConsortium)
		consortiumExpenses.PUT("/liquidate-by-period/:consortium_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.LiquidateConsortiumExpensesByPeriod)
	}

	// UnitExpense routes
	unitExpenses := router.Group("/unit-expenses")
	{
		unitExpenses.GET("", middlewares.AuthMiddleware(), controllers.GetAllUnitExpenses)
		unitExpenses.GET("/:unit_id", middlewares.AuthMiddleware(), controllers.GetUnitExpensesByUnit)
		unitExpenses.POST("", middlewares.AuthMiddleware(), controllers.CreateUnitExpense)
		unitExpenses.PUT("/:id", middlewares.AuthMiddleware(), controllers.UpdateUnitExpense)
		unitExpenses.DELETE("/:id", middlewares.AuthMiddleware(), controllers.DeleteUnitExpense)
		unitExpenses.GET("/status/:unit_id", middlewares.AuthMiddleware(), controllers.GetUnitExpensesByUnitAndStatus)
		unitExpenses.PUT("/liquidate/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.LiquidateUnitExpense)
		unitExpenses.PUT("/liquidate-by-period/:unit_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.LiquidateUnitExpensesByPeriod)
		unitExpenses.POST("/:unit_expense_id/pay", middlewares.AuthMiddleware(), controllers.MakePayment) // POST /unit-expenses/:unit_expense_id/pay
		unitExpenses.POST("/auto-pay", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AutoPayUnitExpensesHandler)
	}

	// Dashboard routes

	router.GET("/dashboard/summary", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.GetDashboardSummary)

	// Documents routes
	documents := router.Group("/documents")
	{
		documents.GET("/:document_id", middlewares.AuthMiddleware(), controllers.ServeDocument)
		documents.POST("/upload", middlewares.AuthMiddleware(), controllers.UploadDocument)
		documents.GET("/consortium/:consortium_id", middlewares.AuthMiddleware(), controllers.GetDocumentsByConsortium)
		documents.GET("/unit/:unit_id", middlewares.AuthMiddleware(), controllers.GetDocumentsByUnit)
		documents.GET("/name/:document_name", middlewares.AuthMiddleware(), controllers.GetDocumentByName)
		documents.GET("", middlewares.AuthMiddleware(), controllers.GetAllDocuments)
		documents.DELETE("/:document_id", middlewares.AuthMiddleware(), controllers.DeleteDocumentByID)

	}

	// Notification routes
	notifications := router.Group("/notifications")
	{
		notifications.POST("/", middlewares.AuthMiddleware(), controllers.CreateNotification)
		notifications.PUT("/:id/mark-read", middlewares.AuthMiddleware(), controllers.MarkNotificationAsRead)
		notifications.GET("/user/:user_id", middlewares.AuthMiddleware(), controllers.GetNotificationsByUser)
		notifications.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteNotification)
		notifications.GET("/role/:role", middlewares.AuthMiddleware(), controllers.GetNotificationsByTargetRole)
		notifications.GET("/unit/:unit_id", middlewares.AuthMiddleware(), controllers.GetNotificationsByTargetUnit)
		notifications.GET("/consortium/:consortium_id", middlewares.AuthMiddleware(), controllers.GetNotificationsByTargetConsortium)
	}

	// Service Management Routes
	services := router.Group("/services")
	{
		services.POST("/", middlewares.AuthMiddleware(), controllers.CreateServiceForConsortium)
		services.GET("/consortium/:consortium_id", middlewares.AuthMiddleware(), controllers.GetServicesByConsortium)
		services.GET("/", middlewares.AuthMiddleware(), controllers.GetAllServices)
		services.PUT("/:service_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateService)
		services.DELETE("/:service_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteServiceByID)
	}

	// Spaces Management Routes
	spaces := router.Group("/spaces")
	{
		spaces.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateSpace)
		spaces.GET("/consortium/:consortium_id", middlewares.AuthMiddleware(), controllers.GetSpacesByConsortium)
		spaces.PUT("/:space_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateSpace)
		spaces.DELETE("/:space_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteSpace)
	}

	// Reservations routes
	reservations := router.Group("/reservations")
	{
		reservations.GET("", middlewares.AuthMiddleware(), controllers.GetAllReservations)
		reservations.POST("", middlewares.AuthMiddleware(), controllers.CreateReservation)
		reservations.GET("/history", middlewares.AuthMiddleware(), controllers.GetReservationHistory)
		reservations.DELETE("/:reservation_id", middlewares.AuthMiddleware(), controllers.DeleteReservation)

	}

	// Health check route
	router.GET("/health-check", controllers.HealthCheck)

}
