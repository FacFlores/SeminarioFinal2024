package main

import (
	"backend/config"
	"backend/routes"
	"backend/utils"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load environment variables
	utils.LoadEnv()

	// Set Gin mode
	ginMode := utils.GetEnv("GIN_MODE", "debug")
	gin.SetMode(ginMode)
	log.Printf("Running in %s mode", ginMode)

	// Create a new Gin router instance
	r := gin.Default()

	// Connect to database
	config.ConnectDatabase()
	// Setup routes
	routes.SetupRoutes(r)

	// Get the port from the environment variable
	port := utils.GetEnv("PORT", "8080")
	log.Printf("Server running on port %s", port)

	// Run the server
	r.Run()
}
