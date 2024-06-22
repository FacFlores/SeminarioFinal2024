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
		users.GET("", middlewares.AuthMiddleware(), middlewares.UserMiddleware(), controllers.FindUsers) // GET /users
		users.GET("/active", middlewares.AuthMiddleware(), controllers.FindActiveUsers)                  // GET /users/active
		users.GET("/inactive", middlewares.AuthMiddleware(), controllers.FindInactiveUsers)              // GET /users/active
		users.POST("/register", controllers.CreateUser)                                                  // POST /users/register
		users.POST("/login", controllers.Login)                                                          // POST /users/login
	}
	// Admin routes

	admin := router.Group("/admin")
	{
		admin.POST("/register", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateAdmin)                         // POST /admin/register
		admin.PUT("/toggle-user-status/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.ToggleUserActiveStatus) // PUT /admin/toggle-user-status/:id
		admin.DELETE("users/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteUser)                        // DELETE /admin/users/:id

	}

	// Roles routes
	roles := router.Group("/roles")
	{
		roles.GET("", controllers.GetAllRoles)                                                                    // GET /roles
		roles.POST("/name", middlewares.AuthMiddleware(), controllers.GetRoleByName)                              // POST /roles/name
		roles.GET("/:id", middlewares.AuthMiddleware(), controllers.GetRoleByID)                                  // GET /roles/:id
		roles.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateRole)       // POST /roles
		roles.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteRole) // DELETE /roles/:id
	}

	// Owner routes
	owners := router.Group("/owners")
	{
		owners.GET("", middlewares.AuthMiddleware(), controllers.GetAllOwners)                                                                    // GET /owners
		owners.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateOwner)                                     // POST /owners
		owners.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateOwner)                                  // PUT /owners/:id
		owners.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteOwner)                               // DELETE /owners/:id
		owners.PUT("/assign-user/:owner_id/:user_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AssignUserToOwner) // PUT /owners/assign-user/:owner_id/:user_id
		owners.GET("/:id", middlewares.AuthMiddleware(), controllers.GetOwnerByID)                                                                // GET /owners/:id
		owners.POST("/name", middlewares.AuthMiddleware(), controllers.GetOwnerByName)                                                            // POST /owners/name
	}

	// Roomer routes
	roomers := router.Group("/roomers")
	{
		roomers.GET("", middlewares.AuthMiddleware(), controllers.GetAllRoomers)                                                                     // GET /roomers
		roomers.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateRoomer)                                      // POST /roomers
		roomers.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateRoomer)                                   // PUT /roomers/:id
		roomers.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteRoomer)                                // DELETE /roomers/:id
		roomers.PUT("/assign-user/:roomer_id/:user_id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.AssignUserToRoomer) // PUT /roomers/assign-user/:roomer_id/:user_id
		roomers.GET("/:id", middlewares.AuthMiddleware(), controllers.GetRoomerByID)                                                                 // GET /roomers/:id
		roomers.POST("/name", middlewares.AuthMiddleware(), controllers.GetRoomerByName)                                                             // POST /roomers/name
	}

	// Consortium routes
	consortiums := router.Group("/consortiums")
	{
		consortiums.GET("", controllers.GetAllConsortiums)                                                                    // GET /consortiums
		consortiums.GET("/:id", controllers.GetConsortiumByID)                                                                // GET /consortiums/:id
		consortiums.POST("/name", controllers.GetConsortiumByName)                                                            // POST /consortiums/name
		consortiums.POST("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.CreateConsortium)       // POST /consortiums
		consortiums.PUT("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.UpdateConsortium)    // PUT /consortiums/:id
		consortiums.DELETE("/:id", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.DeleteConsortium) // DELETE /consortiums/:id
	}

	// Health check route
	router.GET("/health-check", controllers.HealthCheck) // GET /health-check

}
