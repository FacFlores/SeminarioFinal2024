package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreateNotification(c *gin.Context) {
	var notification models.Notification
	if err := c.ShouldBindJSON(&notification); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	createdNotification, err := services.CreateNotification(notification)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, createdNotification)
}

func MarkNotificationAsRead(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification ID"})
		return
	}

	err = services.MarkNotificationAsRead(uint(id))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification marked as read"})
}

func DeleteNotification(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification ID"})
		return
	}

	err = services.DeleteNotification(uint(id))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification deleted"})
}

func GetNotificationsByTargetRole(c *gin.Context) {
	targetRole := c.Param("role")

	notifications, err := services.GetNotificationsByTargetRole(targetRole)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, notifications)
}

func GetNotificationsByTargetUnit(c *gin.Context) {
	unitIDParam := c.Param("unit_id")
	unitID, err := strconv.ParseUint(unitIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	notifications, err := services.GetNotificationsByTargetUnit(uint(unitID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, notifications)
}

func GetNotificationsByTargetConsortium(c *gin.Context) {
	consortiumIDParam := c.Param("consortium_id")
	consortiumID, err := strconv.ParseUint(consortiumIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	notifications, err := services.GetNotificationsByTargetConsortium(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, notifications)
}
