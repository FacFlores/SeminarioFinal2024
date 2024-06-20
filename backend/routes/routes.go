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
		users.GET("", middlewares.AuthMiddleware(), middlewares.AdminMiddleware(), controllers.FindUsers) // GET /users
		users.POST("/register", controllers.CreateUser)                                                   // POST /users/register
		users.POST("/login", controllers.Login)                                                           // POST /users/login
	}

	// Health check routes
	router.GET("/health-check", controllers.HealthCheck) // GET /health-check

}
