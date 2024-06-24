package services

import (
	"backend/config"
	"backend/models"
	"errors"
)

func CreateUnitExpense(expense models.UnitExpense) (models.UnitExpense, error) {
	if err := config.DB.Create(&expense).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func UpdateUnitExpense(id string, updatedData models.UnitExpense) (models.UnitExpense, error) {
	var expense models.UnitExpense
	if err := config.DB.First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}

	if expense.Liquidated || expense.Paid {
		return expense, errors.New("cannot update a liquidated or paid expense")
	}

	expense.Description = updatedData.Description
	expense.Amount = updatedData.Amount
	expense.LeftToPay = updatedData.LeftToPay
	expense.ConceptID = updatedData.ConceptID
	expense.ExpensePeriod = updatedData.ExpensePeriod
	expense.LiquidatePeriod = updatedData.LiquidatePeriod

	if err := config.DB.Save(&expense).Error; err != nil {
		return expense, err
	}

	return expense, nil
}

func DeleteUnitExpense(id string) error {
	var expense models.UnitExpense
	if err := config.DB.First(&expense, "id = ?", id).Error; err != nil {
		return err
	}

	if expense.Liquidated || expense.Paid {
		return errors.New("cannot delete a liquidated or paid expense")
	}

	if err := config.DB.Delete(&expense).Error; err != nil {
		return err
	}
	return nil
}

func GetAllUnitExpenses() ([]models.UnitExpense, error) {
	var expenses []models.UnitExpense
	if err := config.DB.Preload("Concept").Preload("Unit").Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}

func GetUnitExpensesByUnit(unitID uint) ([]models.UnitExpense, error) {
	var expenses []models.UnitExpense
	if err := config.DB.Preload("Concept").Preload("Unit").Where("unit_id = ?", unitID).Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}

func GetUnitExpensesByUnitAndStatus(unitID uint, liquidated, paid bool) ([]models.UnitExpense, error) {
	var expenses []models.UnitExpense
	if err := config.DB.Preload("Concept").Preload("Unit").Where("unit_id = ? AND liquidated = ? AND paid = ?", unitID, liquidated, paid).Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}
