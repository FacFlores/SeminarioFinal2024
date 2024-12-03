package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetAllReservations(c *gin.Context) {
	consortiumID, err := strconv.Atoi(c.Query("consortium_id"))
	if err != nil || consortiumID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	reservations, err := services.GetAllReservations(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, reservations)
}

func CreateReservation(c *gin.Context) {
	var input struct {
		UserID          uint   `json:"user_id" binding:"required"`
		ConsortiumID    uint   `json:"consortium_id" binding:"required"`
		SpaceID         uint   `json:"space_id" binding:"required"`
		ReservationDate string `json:"reservation_date" binding:"required"` //  format: YYYY-MM-DD
		StartTime       string `json:"start_time" binding:"required"`       //  format: HH:MM
		EndTime         string `json:"end_time" binding:"required"`         //  format: HH:MM
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	reservation := models.Reservation{
		UserID:          input.UserID,
		ConsortiumID:    input.ConsortiumID,
		SpaceID:         input.SpaceID,
		ReservationDate: input.ReservationDate,
		StartTime:       input.StartTime,
		EndTime:         input.EndTime,
		Status:          "active",
	}

	if err := services.CreateReservation(&reservation); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, reservation)
}

func GetReservationHistory(c *gin.Context) {
	consortiumID, err := strconv.Atoi(c.Query("consortium_id"))
	if err != nil || consortiumID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	reservations, err := services.GetReservationHistory(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, reservations)
}

func DeleteReservation(c *gin.Context) {
	reservationID, err := strconv.Atoi(c.Param("reservation_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid reservation ID"})
		return
	}

	if err := services.DeleteReservation(uint(reservationID)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Reservation deleted successfully"})
}
