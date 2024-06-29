package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"
	"time"

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
	id, parseErr := strconv.ParseUint(idParam, 10, 32)

	if parseErr != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

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

func CreateConsortiumService(c *gin.Context) {
	var input struct {
		ConsortiumID  uint   `json:"consortium_id"`
		Name          string `json:"name"`
		Description   string `json:"description"`
		ScheduledDate string `json:"scheduled_date"`
		ExpiryDate    string `json:"expiry_date"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	scheduledDate, err := time.Parse(time.RFC3339, input.ScheduledDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid scheduled date"})
		return
	}

	expiryDate, err := time.Parse(time.RFC3339, input.ExpiryDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid expiry date"})
		return
	}

	service, err := services.CreateConsortiumService(input.ConsortiumID, input.Name, input.Description, scheduledDate, expiryDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, service)
}

func GetConsortiumServices(c *gin.Context) {
	consortiumIDParam := c.Param("consortium_id")
	consortiumID, err := strconv.ParseUint(consortiumIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	services, err := services.GetConsortiumServices(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, services)
}

func UpdateConsortiumServiceStatus(c *gin.Context) {
	serviceIDParam := c.Param("service_id")
	serviceID, err := strconv.ParseUint(serviceIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid service ID"})
		return
	}

	var input struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = services.UpdateConsortiumServiceStatus(uint(serviceID), input.Status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Service status updated"})
}

func ScheduleNextMaintenance(c *gin.Context) {
	serviceIDParam := c.Param("service_id")
	serviceID, err := strconv.ParseUint(serviceIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid service ID"})
		return
	}

	var input struct {
		NextMaintenance string `json:"next_maintenance"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	nextMaintenance, err := time.Parse(time.RFC3339, input.NextMaintenance)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid next maintenance date"})
		return
	}

	err = services.ScheduleNextMaintenance(uint(serviceID), nextMaintenance)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Next maintenance scheduled"})
}
