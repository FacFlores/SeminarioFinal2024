package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetAllOwners(c *gin.Context) {
	owners, err := services.GetAllOwners()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, owners)
}

func GetOwnerByID(c *gin.Context) {
	id := c.Param("id")

	owner, err := services.GetOwnerByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Owner not found"})
		return
	}

	c.JSON(http.StatusOK, owner)
}

func GetOwnerByName(c *gin.Context) {
	var input struct {
		Name string `json:"name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	owner, err := services.GetOwnerByName(input.Name)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Owner not found"})
		return
	}

	c.JSON(http.StatusOK, owner)
}

func CreateOwner(c *gin.Context) {
	var input struct {
		Name    string `json:"name" binding:"required"`
		Surname string `json:"surname" binding:"required"`
		Phone   string `json:"phone" binding:"required"`
		Dni     string `json:"dni" binding:"required"`
		Cuit    string `json:"cuit" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	owner := models.Owner{
		Name:    input.Name,
		Surname: input.Surname,
		Phone:   input.Phone,
		Dni:     input.Dni,
		Cuit:    input.Cuit,
	}

	createdOwner, err := services.CreateOwner(owner)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdOwner)
}

func UpdateOwner(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Name    string `json:"name"`
		Surname string `json:"surname"`
		Phone   string `json:"phone"`
		Dni     string `json:"dni"`
		Cuit    string `json:"cuit"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedOwner, err := services.UpdateOwner(id, models.Owner{
		Name:    input.Name,
		Surname: input.Surname,
		Phone:   input.Phone,
		Dni:     input.Dni,
		Cuit:    input.Cuit,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedOwner)
}

func DeleteOwner(c *gin.Context) {
	id := c.Param("id")

	if err := services.DeleteOwner(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Owner deleted"})
}