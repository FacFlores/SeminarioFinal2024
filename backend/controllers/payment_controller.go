package controllers

import (
	"backend/services"
	"net/http"
	"strconv"
	"time"

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

type AutoPayRequest struct {
	UnitID    uint    `json:"unit_id" binding:"required"`
	Amount    float64 `json:"amount" binding:"required"`
	Year      int     `json:"year" binding:"required"`
	Month     int     `json:"month" binding:"required"`
	ConceptID uint    `json:"concept_id" binding:"required"`
}

func AutoPayUnitExpensesHandler(c *gin.Context) {
	var req AutoPayRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	payments, err := services.AutoPayUnitExpenses(req.UnitID, req.Amount, req.Year, time.Month(req.Month), req.ConceptID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"payments": payments})
}
