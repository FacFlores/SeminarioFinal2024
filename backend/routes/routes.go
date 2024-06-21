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

	// Health check route
	router.GET("/health-check", controllers.HealthCheck) // GET /health-check

}
