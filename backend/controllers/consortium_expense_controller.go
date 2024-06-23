package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateConsortiumExpense(c *gin.Context) {
	var input struct {
		Description   string    `json:"description"`
		Amount        float64   `json:"amount" binding:"required"`
		ConceptID     uint      `json:"concept_id" binding:"required"`
		ExpensePeriod time.Time `json:"period" binding:"required"`
		ConsortiumID  uint      `json:"consortium_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	expense := models.ConsortiumExpense{
		Description:   input.Description,
		Amount:        input.Amount,
		ConceptID:     input.ConceptID,
		ExpensePeriod: input.ExpensePeriod,
		ConsortiumID:  input.ConsortiumID,
		Distributed:   false,
	}

	createdExpense, err := services.CreateConsortiumExpense(expense)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, createdExpense)
}

func GetConsortiumExpenseByID(c *gin.Context) {
	id := c.Param("id")

	expense, err := services.GetConsortiumExpenseByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Expense not found"})
		return
	}

	c.JSON(http.StatusOK, expense)
}

func GetAllConsortiumExpenses(c *gin.Context) {
	expenses, err := services.GetAllConsortiumExpenses()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, expenses)
}

func UpdateConsortiumExpense(c *gin.Context) {
	id := c.Param("id")

	var input models.ConsortiumExpense
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	expense, err := services.UpdateConsortiumExpense(id, input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, expense)
}

func DeleteConsortiumExpense(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteConsortiumExpense(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Expense deleted"})
}