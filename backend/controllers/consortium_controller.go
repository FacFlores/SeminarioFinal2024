package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreateConsortium(c *gin.Context) {
	var input struct {
		Name    string `json:"name" binding:"required"`
		Address string `json:"address"`
		Cuit    string `json:"cuit"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	consortium := models.Consortium{
		Name:    input.Name,
		Address: input.Address,
		Cuit:    input.Cuit,
	}

	createdConsortium, err := services.CreateConsortium(consortium)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdConsortium)
}

func GetConsortiumByID(c *gin.Context) {
	id := c.Param("id")

	consortium, err := services.GetConsortiumByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Consortium not found"})
		return
	}

	c.JSON(http.StatusOK, consortium)
}

func GetConsortiumByName(c *gin.Context) {
	var input struct {
		Name string `json:"name" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	consortium, err := services.GetConsortiumByName(input.Name)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Consortium not found"})
		return
	}

	c.JSON(http.StatusOK, consortium)
}

func GetAllConsortiums(c *gin.Context) {
	consortiums, err := services.GetAllConsortiums()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, consortiums)
}

func UpdateConsortium(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 32)

	var input struct {
		Name    string `json:"name"`
		Address string `json:"address"`
		Cuit    string `json:"cuit"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedConsortium, err := services.UpdateConsortium(uint(id), models.Consortium{
		Name:    input.Name,
		Address: input.Address,
		Cuit:    input.Cuit,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedConsortium)
}

func DeleteConsortium(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteConsortium(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Consortium deleted"})
}

func GetConsortiumByUnit(c *gin.Context) {
	unitIDStr := c.Param("unit_id")
	unitID, err := strconv.ParseUint(unitIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	consortium, err := services.GetConsortiumByUnit(uint(unitID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, consortium)
}
