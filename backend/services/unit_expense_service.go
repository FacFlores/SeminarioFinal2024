package services

import (
	"backend/config"
	"backend/models"
	"errors"
	"time"
)

func CreateUnitExpense(expense models.UnitExpense) (models.UnitExpense, error) {
	if err := config.DB.Create(&expense).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func LiquidateUnitExpense(expenseID uint) (models.UnitExpense, error) {
	var expense models.UnitExpense
	if err := config.DB.First(&expense, "id = ?", expenseID).Error; err != nil {
		return expense, errors.New("unit expense not found")
	}

	if expense.Liquidated {
		return expense, errors.New("expense is already liquidated")
	}

	expense.Liquidated = true

	var ledger models.UnitLedger
	if err := config.DB.First(&ledger, "unit_id = ?", expense.UnitID).Error; err != nil {
		return expense, errors.New("unit ledger not found")
	}

	ledger.Balance -= expense.Amount

	if err := config.DB.Save(&ledger).Error; err != nil {
		return expense, err
	}

	if err := config.DB.Save(&expense).Error; err != nil {
		return expense, err
	}

	return expense, nil
}

func LiquidateUnitExpensesByPeriod(unitID uint, period time.Time) error {
	startOfMonth := time.Date(period.Year(), period.Month(), 1, 0, 0, 0, 0, time.UTC)
	endOfMonth := startOfMonth.AddDate(0, 1, 0).Add(-time.Nanosecond)

	var expenses []models.UnitExpense
	if err := config.DB.Where("unit_id = ? AND liquidate_period BETWEEN ? AND ? AND liquidated = ?", unitID, startOfMonth, endOfMonth, false).Find(&expenses).Error; err != nil {
		return errors.New("unit expenses not found")
	}

	for _, expense := range expenses {
		expense.Liquidated = true

		transaction := models.Transaction{
			UnitLedgerID: unitID,
			Amount:       expense.Amount,
			Description:  expense.Description,
			ConceptID:    expense.ConceptID,
			ExpenseID:    &expense.ID,
		}

		if _, err := RecordTransaction(transaction); err != nil {
			return err
		}

		if err := config.DB.Save(&expense).Error; err != nil {
			return err
		}
	}

	return nil
}

func LiquidateConsortiumExpensesByPeriod(consortiumID uint, period time.Time) error {
	var expenses []models.ConsortiumExpense
	if err := config.DB.Where("consortium_id = ? AND liquidate_period = ? AND distributed = ?", consortiumID, period, false).Find(&expenses).Error; err != nil {
		return errors.New("consortium expenses not found")
	}

	for _, expense := range expenses {
		expense.Distributed = true
		if err := config.DB.Save(&expense).Error; err != nil {
			return err
		}
	}

	var units []models.Unit
	if err := config.DB.Where("consortium_id = ?", consortiumID).Find(&units).Error; err != nil {
		return errors.New("could not find units")
	}

	for _, unit := range units {
		if err := LiquidateUnitExpensesByPeriod(unit.ID, period); err != nil {
			return err
		}
	}

	return nil
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
