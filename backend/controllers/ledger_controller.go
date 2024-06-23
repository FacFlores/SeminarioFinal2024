package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func RecordTransaction(c *gin.Context) {
	var input struct {
		UnitLedgerID uint    `json:"unit_ledger_id" binding:"required"`
		Amount       float64 `json:"amount" binding:"required"`
		Description  string  `json:"description"`
		ConceptID    uint    `json:"concept_id" binding:"required"`
		ExpenseID    *uint   `json:"expense_id"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	transaction := models.Transaction{
		UnitLedgerID: input.UnitLedgerID,
		Amount:       input.Amount,
		Description:  input.Description,
		ConceptID:    input.ConceptID,
		ExpenseID:    input.ExpenseID,
	}

	createdTransaction, err := services.RecordTransaction(transaction)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, createdTransaction)
}

func GetUnitBalance(c *gin.Context) {
	unitID, err := strconv.Atoi(c.Param("unit_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid unit id"})
		return
	}

	balance, err := services.GetUnitBalance(uint(unitID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"balance": balance})
}

func GetUnitTransactions(c *gin.Context) {
	unitID, err := strconv.Atoi(c.Param("unit_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid unit id"})
		return
	}

	transactions, err := services.GetUnitTransactions(uint(unitID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, transactions)
}
