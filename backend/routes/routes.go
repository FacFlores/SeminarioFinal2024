package routes

import (
	"backend/controllers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	router.GET("/users", controllers.FindUsers)
	router.POST("/users", controllers.CreateUser)
}
