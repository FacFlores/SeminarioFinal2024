package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func CreateCoefficient(c *gin.Context) {
	var input struct {
		Name          string `json:"name" binding:"required"`
		Distributable *bool  `json:"distributable" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	coefficient := models.Coefficient{
		Name:          input.Name,
		Distributable: *input.Distributable,
	}

	createdCoefficient, err := services.CreateCoefficient(coefficient)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdCoefficient)
}

func GetCoefficientByID(c *gin.Context) {
	id := c.Param("id")

	coefficient, err := services.GetCoefficientByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Coefficient not found"})
		return
	}

	c.JSON(http.StatusOK, coefficient)
}

func GetAllCoefficients(c *gin.Context) {
	coefficients, err := services.GetAllCoefficients()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, coefficients)
}

func UpdateCoefficient(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Name          string `json:"name"`
		Distributable *bool  `json:"distributable"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedCoefficient, err := services.UpdateCoefficient(id, models.Coefficient{
		Name:          input.Name,
		Distributable: *input.Distributable,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedCoefficient)
}

func DeleteCoefficient(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteCoefficient(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Coefficient deleted"})
}
