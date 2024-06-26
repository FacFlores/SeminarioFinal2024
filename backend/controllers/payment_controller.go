package controllers

import (
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func MakePayment(c *gin.Context) {
	var input struct {
		Amount      float64 `json:"amount" binding:"required"`
		Description string  `json:"description"`
		ConceptID   uint    `json:"concept_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	unitExpenseIDParam := c.Param("unit_expense_id")
	unitExpenseID, err := strconv.ParseUint(unitExpenseIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit expense ID"})
		return
	}

	payment, err := services.MakePayment(uint(unitExpenseID), input.Amount, input.Description, input.ConceptID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, payment)
}
