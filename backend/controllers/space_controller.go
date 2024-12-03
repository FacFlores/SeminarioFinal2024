package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreateSpace(c *gin.Context) {
	var input struct {
		Name                 string `json:"name" binding:"required"`
		ConsortiumID         uint   `json:"consortium_id" binding:"required"`
		OperationalStartTime string `json:"operational_start_time" binding:"required"`
		OperationalEndTime   string `json:"operational_end_time" binding:"required"`
		Status               string `json:"status"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	space := models.Space{
		Name:                 input.Name,
		ConsortiumID:         input.ConsortiumID,
		OperationalStartTime: input.OperationalStartTime,
		OperationalEndTime:   input.OperationalEndTime,
		Status:               input.Status,
	}

	if err := services.CreateSpace(&space); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, space)
}

func GetSpacesByConsortium(c *gin.Context) {
	consortiumID, err := strconv.Atoi(c.Param("consortium_id"))
	if err != nil || consortiumID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	spaces, err := services.GetSpacesByConsortium(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, spaces)
}

func UpdateSpace(c *gin.Context) {
	spaceID, err := strconv.Atoi(c.Param("space_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid space ID"})
		return
	}

	var input struct {
		Name                 string `json:"name"`
		OperationalStartTime string `json:"operational_start_time"`
		OperationalEndTime   string `json:"operational_end_time"`
		Status               string `json:"status"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updateData := make(map[string]interface{})

	if input.Name != "" {
		updateData["name"] = input.Name
	}
	if input.OperationalStartTime != "" {
		updateData["operational_start_time"] = input.OperationalStartTime
	}
	if input.OperationalEndTime != "" {
		updateData["operational_end_time"] = input.OperationalEndTime
	}
	if input.Status != "" {
		updateData["status"] = input.Status
	}

	if err := services.UpdateSpace(uint(spaceID), updateData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Space updated successfully"})
}

func DeleteSpace(c *gin.Context) {
	spaceID, err := strconv.Atoi(c.Param("space_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid space ID"})
		return
	}

	if err := services.DeleteSpace(uint(spaceID)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Space deleted successfully"})
}
