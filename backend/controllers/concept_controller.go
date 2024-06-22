package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func CreateConcept(c *gin.Context) {
	var input struct {
		Name          string `json:"name" binding:"required"`
		Priority      *int   `json:"priority" binding:"required"`
		Origin        string `json:"origin" binding:"required"` // "Debe" or "Haber"
		Type          string `json:"type" binding:"required"`
		Description   string `json:"description"`
		CoefficientID uint   `json:"coefficient_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	concept := models.Concept{
		Name:          input.Name,
		Priority:      *input.Priority,
		Origin:        input.Origin,
		Type:          input.Type,
		Description:   input.Description,
		CoefficientID: input.CoefficientID,
	}

	if input.Origin != "Debe" && input.Origin != "Haber" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Type must be 'Debe' or 'Haber'"})
		return
	}

	createdConcept, err := services.CreateConcept(concept)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdConcept)
}

func GetConceptByID(c *gin.Context) {
	id := c.Param("id")

	concept, err := services.GetConceptByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Concept not found"})
		return
	}

	c.JSON(http.StatusOK, concept)
}

func GetAllConcepts(c *gin.Context) {
	concepts, err := services.GetAllConcepts()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, concepts)
}

func UpdateConcept(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Name          string `json:"name"`
		Priority      int    `json:"priority"`
		Origin        string `json:"origin"`
		Type          string `json:"type"`
		Description   string `json:"description"`
		CoefficientID uint   `json:"coefficient_id"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if input.Origin != "Debe" && input.Origin != "Haber" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Type must be 'Debe' or 'Haber'"})
		return
	}

	updatedConcept, err := services.UpdateConcept(id, models.Concept{
		Name:          input.Name,
		Priority:      input.Priority,
		Origin:        input.Origin,
		Type:          input.Type,
		Description:   input.Description,
		CoefficientID: input.CoefficientID,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedConcept)
}

func DeleteConcept(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteConcept(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Concept deleted"})
}
