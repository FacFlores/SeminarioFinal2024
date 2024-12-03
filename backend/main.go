package main

import (
	"backend/config"
	"backend/routes"
	"backend/utils"
	"log"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	utils.LoadEnv()
	ginMode := utils.GetEnv("GIN_MODE", "debug")
	gin.SetMode(ginMode)
	log.Printf("Running in %s mode", ginMode)
	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))
	config.ConnectDatabase()
	routes.SetupRoutes(r)
	r.Run()
}
