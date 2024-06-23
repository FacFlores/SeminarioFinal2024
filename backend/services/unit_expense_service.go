package services

import (
	"backend/config"
	"backend/models"
)

func CreateUnitExpense(expense models.UnitExpense) (models.UnitExpense, error) {
	if err := config.DB.Create(&expense).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func GetUnitExpenseByID(id string) (models.UnitExpense, error) {
	var expense models.UnitExpense
	if err := config.DB.First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func GetAllUnitExpenses() ([]models.UnitExpense, error) {
	var expenses []models.UnitExpense
	if err := config.DB.Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}

func UpdateUnitExpense(id string, updatedData models.UnitExpense) (models.UnitExpense, error) {
	var expense models.UnitExpense
	if err := config.DB.First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}

	expense.Description = updatedData.Description
	expense.Amount = updatedData.Amount
	expense.LeftToPay = updatedData.LeftToPay
	expense.ConceptID = updatedData.ConceptID
	expense.ExpensePeriod = updatedData.ExpensePeriod
	expense.LiquidatePeriod = updatedData.LiquidatePeriod
	expense.Liquidated = updatedData.Liquidated
	expense.Paid = updatedData.Paid
	expense.UnitID = updatedData.UnitID
	expense.ConsortiumExpenseID = updatedData.ConsortiumExpenseID

	if err := config.DB.Save(&expense).Error; err != nil {
		return expense, err
	}

	return expense, nil
}

func DeleteUnitExpense(id string) error {
	if err := config.DB.Delete(&models.UnitExpense{}, id).Error; err != nil {
		return err
	}
	return nil
}
