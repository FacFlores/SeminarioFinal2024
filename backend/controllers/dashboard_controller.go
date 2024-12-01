package controllers

import (
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetDashboardSummary(c *gin.Context) {
	dashboardData, err := services.GetAdminDashboardData()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, dashboardData)

}
