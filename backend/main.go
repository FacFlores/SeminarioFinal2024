package main

import (
	"backend/config"
	"backend/routes"
	"backend/utils"

	"github.com/gin-gonic/gin"
)

func main() {
	utils.LoadEnv()
	// Set Gin mode
	ginMode := utils.GetEnv("GIN_MODE", "debug")
	gin.SetMode(ginMode)

	r := gin.Default()

	// Connect to database
	config.ConnectDatabase()

	// Setup routes
	routes.SetupRoutes(r)

	// Run the server
	r.Run()
}
