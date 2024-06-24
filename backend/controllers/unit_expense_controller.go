package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateUnitExpense(c *gin.Context) {
	var input struct {
		Description     string    `json:"description"`
		Amount          float64   `json:"amount" binding:"required"`
		ConceptID       uint      `json:"concept_id" binding:"required"`
		ExpensePeriod   time.Time `json:"expense_period" binding:"required"`
		LiquidatePeriod time.Time `json:"liquidate_period" binding:"required"`
		UnitID          uint      `json:"unit_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	unit, err := services.GetUnitByID(input.UnitID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Unit not found"})
		return
	}

	consortium, err := services.GetConsortiumByID(strconv.Itoa(int(unit.ConsortiumID)))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Consortium not found"})
		return
	}

	expense := models.UnitExpense{
		Description:     input.Description,
		Amount:          input.Amount,
		LeftToPay:       input.Amount,
		ConceptID:       input.ConceptID,
		ExpensePeriod:   input.ExpensePeriod,
		LiquidatePeriod: input.LiquidatePeriod,
		UnitID:          input.UnitID,
		Liquidated:      false,
		Paid:            false,
		BillNumber:      consortium.BillNumber + 1,
	}

	consortium.BillNumber++

	services.UpdateConsortium(consortium.ID, consortium)

	createdExpense, err := services.CreateUnitExpense(expense)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, createdExpense)
}

func UpdateUnitExpense(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Description     string    `json:"description"`
		Amount          float64   `json:"amount" binding:"required"`
		LeftToPay       float64   `json:"left_to_pay" binding:"required"`
		ConceptID       uint      `json:"concept_id" binding:"required"`
		ExpensePeriod   time.Time `json:"expense_period" binding:"required"`
		LiquidatePeriod time.Time `json:"liquidate_period" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedData := models.UnitExpense{
		Description:     input.Description,
		Amount:          input.Amount,
		LeftToPay:       input.LeftToPay,
		ConceptID:       input.ConceptID,
		ExpensePeriod:   input.ExpensePeriod,
		LiquidatePeriod: input.LiquidatePeriod,
	}

	updatedExpense, err := services.UpdateUnitExpense(id, updatedData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedExpense)
}

func DeleteUnitExpense(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteUnitExpense(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Unit expense deleted"})
}

func GetAllUnitExpenses(c *gin.Context) {
	expenses, err := services.GetAllUnitExpenses()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, expenses)
}

func GetUnitExpensesByUnit(c *gin.Context) {
	unitIDParam := c.Param("unit_id")
	unitID, err := strconv.ParseUint(unitIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	expenses, err := services.GetUnitExpensesByUnit(uint(unitID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, expenses)
}

func GetUnitExpensesByUnitAndStatus(c *gin.Context) {
	unitIDParam := c.Param("unit_id")
	unitID, err := strconv.ParseUint(unitIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	liquidated := c.Query("liquidated") == "true"
	paid := c.Query("paid") == "true"

	expenses, err := services.GetUnitExpensesByUnitAndStatus(uint(unitID), liquidated, paid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, expenses)
}
