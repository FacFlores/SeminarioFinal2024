package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetAllRoomers(c *gin.Context) {
	roomers, err := services.GetAllRoomers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, roomers)
}
func GetRoomersNotLinkedToUser(c *gin.Context) {
	roomers, err := services.GetRoomersNotLinkedToUser()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, roomers)
}

func GetRoomersByUserID(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	roomers, err := services.GetRoomersByUserID(uint(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, roomers)
}

func RemoveUserFromRoomer(c *gin.Context) {
	roomerIDStr := c.Param("roomer_id")

	roomerID, err := strconv.ParseUint(roomerIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid roomer ID"})
		return
	}

	roomer, err := services.RemoveUserFromRoomer(uint(roomerID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, roomer)
}

func GetRoomerByID(c *gin.Context) {
	id := c.Param("id")

	roomer, err := services.GetRoomerByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Roomer not found"})
		return
	}

	c.JSON(http.StatusOK, roomer)
}

func GetRoomerByName(c *gin.Context) {
	var input struct {
		Name string `json:"name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	roomer, err := services.GetRoomerByName(input.Name)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Roomer not found"})
		return
	}

	c.JSON(http.StatusOK, roomer)
}

func CreateRoomer(c *gin.Context) {
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

	roomer := models.Roomer{
		Name:    input.Name,
		Surname: input.Surname,
		Phone:   input.Phone,
		Dni:     input.Dni,
		Cuit:    input.Cuit,
	}

	createdRoomer, err := services.CreateRoomer(roomer)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdRoomer)
}

func UpdateRoomer(c *gin.Context) {
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

	updatedRoomer, err := services.UpdateRoomer(id, models.Roomer{
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

	c.JSON(http.StatusOK, updatedRoomer)
}

func DeleteRoomer(c *gin.Context) {
	id := c.Param("id")

	if err := services.DeleteRoomer(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Roomer deleted"})
}

func AssignUserToRoomer(c *gin.Context) {
	roomerIDStr := c.Param("roomer_id")
	userIDStr := c.Param("user_id")

	roomerID, err := strconv.ParseUint(roomerIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid roomer ID"})
		return
	}

	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	roomer, err := services.AssignUserToRoomer(uint(roomerID), uint(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, roomer)
}
