package controllers

import (
	"backend/config"
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreateNotification(c *gin.Context) {
	var input struct {
		Title              string  `json:"title" binding:"required"`
		Message            string  `json:"message" binding:"required"`
		TargetUserID       *uint   `json:"target_user_id"`
		TargetRole         *string `json:"target_role"`
		TargetUnitID       *uint   `json:"target_unit_id"`
		TargetConsortiumID *uint   `json:"target_consortium_id"`
		SenderUserID       uint    `json:"sender_user_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	notification := models.Notification{
		Title:              input.Title,
		Message:            input.Message,
		TargetUserID:       input.TargetUserID,
		TargetRole:         input.TargetRole,
		TargetUnitID:       input.TargetUnitID,
		TargetConsortiumID: input.TargetConsortiumID,
		SenderUserID:       input.SenderUserID,
		IsRead:             false,
	}

	createdNotification, err := services.CreateNotification(notification)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if err := config.DB.Preload("SenderUser").First(&createdNotification, createdNotification.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, createdNotification)
}

func GetNotificationsByTargetRole(c *gin.Context) {
	role := c.Param("role")
	notifications, err := services.GetNotificationsByTargetRole(role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, notifications)
}

func GetNotificationsByTargetUnit(c *gin.Context) {
	unitID, err := strconv.ParseUint(c.Param("unit_id"), 10, 64)
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
	consortiumID, err := strconv.ParseUint(c.Param("consortium_id"), 10, 64)
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

func GetNotificationsByUser(c *gin.Context) {
	userID := c.Param("user_id")

	notifications, err := services.GetNotificationsByUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, notifications)
}

func MarkNotificationAsRead(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification ID"})
		return
	}

	if err := services.MarkNotificationAsRead(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark notification as read"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification marked as read"})
}

func DeleteNotification(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification ID"})
		return
	}

	if err := services.DeleteNotification(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete notification"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification deleted"})
}
