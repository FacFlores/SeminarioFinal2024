package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func UpdateUnitCoefficients(c *gin.Context) {
	var input struct {
		CoefficientID uint                     `json:"coefficient_id" binding:"required"`
		ConsortiumID  uint                     `json:"consortium_id" binding:"required"`
		Units         []models.UnitCoefficient `json:"units" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedUnitCoefficients, err := services.UpdateUnitCoefficients(input.CoefficientID, input.ConsortiumID, input.Units)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedUnitCoefficients)
}

func GetUnitsWithCoefficients(c *gin.Context) {
	var input struct {
		ConsortiumID  uint `json:"consortium_id" binding:"required"`
		CoefficientID uint `json:"coefficient_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	unitsCoefficients, err := services.GetUnitsWithCoefficientsByConsortiumAndCoefficient(input.ConsortiumID, input.CoefficientID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, unitsCoefficients)
}
