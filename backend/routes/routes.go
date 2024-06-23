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
	}
	// Admin routes

	admin := router.Group("/admin")
	{
		admin.POST("/register", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateAdmin)
		admin.PUT("/toggle-user-status/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.ToggleUserActiveStatus)
		admin.DELETE("users/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteUser)

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
	}

	// ConsortiumExpense routes
	consortiumExpenses := router.Group("/consortium-expenses")
	{
		consortiumExpenses.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateConsortiumExpense)
		consortiumExpenses.GET("/:id", middlewares.AuthMiddleware(), controllers.GetConsortiumExpenseByID)
		consortiumExpenses.GET("", middlewares.AuthMiddleware(), controllers.GetAllConsortiumExpenses)
		consortiumExpenses.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateConsortiumExpense)
		consortiumExpenses.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteConsortiumExpense)
	}

	// UnitExpense routes
	unitExpenses := router.Group("/unit-expenses")
	{
		unitExpenses.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateUnitExpense)
		unitExpenses.GET("/:id", middlewares.AuthMiddleware(), controllers.GetUnitExpenseByID)
		unitExpenses.GET("", middlewares.AuthMiddleware(), controllers.GetAllUnitExpenses)
		unitExpenses.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateUnitExpense)
		unitExpenses.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteUnitExpense)
	}

	// Health check route
	router.GET("/health-check", controllers.HealthCheck) // GET /health-check

}
