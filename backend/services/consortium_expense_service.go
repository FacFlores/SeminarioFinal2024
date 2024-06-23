package services

import (
	"backend/config"
	"backend/models"
	"errors"
)

func CreateConsortiumExpense(expense models.ConsortiumExpense) (models.ConsortiumExpense, error) {
	var consortium models.Consortium
	if err := config.DB.First(&consortium, "id = ?", expense.ConsortiumID).Error; err != nil {
		return expense, errors.New("consortium not found")
	}

	expense.BillNumber = consortium.BillNumber + 1
	consortium.BillNumber++

	if err := config.DB.Save(&consortium).Error; err != nil {
		return expense, err
	}

	if err := config.DB.Create(&expense).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func GetConsortiumExpenseByID(id string) (models.ConsortiumExpense, error) {
	var expense models.ConsortiumExpense
	if err := config.DB.First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func GetAllConsortiumExpenses() ([]models.ConsortiumExpense, error) {
	var expenses []models.ConsortiumExpense
	if err := config.DB.Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}

func UpdateConsortiumExpense(id string, updatedData models.ConsortiumExpense) (models.ConsortiumExpense, error) {
	var expense models.ConsortiumExpense
	if err := config.DB.First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}

	expense.Description = updatedData.Description
	expense.Amount = updatedData.Amount
	expense.ConceptID = updatedData.ConceptID
	expense.ExpensePeriod = updatedData.ExpensePeriod
	expense.Distributed = updatedData.Distributed

	if err := config.DB.Save(&expense).Error; err != nil {
		return expense, err
	}

	return expense, nil
}

func DeleteConsortiumExpense(id string) error {
	if err := config.DB.Delete(&models.ConsortiumExpense{}, id).Error; err != nil {
		return err
	}
	return nil
}
