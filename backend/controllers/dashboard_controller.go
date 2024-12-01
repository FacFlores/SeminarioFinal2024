package controllers

import (
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetDashboardSummary(c *gin.Context) {
	summary, err := services.GetDashboardSummary()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	consortiumMetrics, err := services.GetConsortiumMetrics()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	unitMetrics, err := services.GetUnitMetrics()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := map[string]interface{}{
		"summary":           summary,
		"consortiumMetrics": consortiumMetrics,
		"unitMetrics":       unitMetrics,
	}

	c.JSON(http.StatusOK, response)
}
