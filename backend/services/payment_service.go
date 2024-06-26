package services

import (
	"backend/config"
	"backend/models"
	"errors"
)

func MakePayment(unitExpenseID uint, amount float64, description string, conceptID uint) (models.Payment, error) {
	var unitExpense models.UnitExpense
	if err := config.DB.First(&unitExpense, "id = ?", unitExpenseID).Error; err != nil {
		return models.Payment{}, errors.New("unit expense not found")
	}

	if unitExpense.LeftToPay <= 0 {
		return models.Payment{}, errors.New("unit expense is already fully paid")
	}

	if amount > unitExpense.LeftToPay {
		return models.Payment{}, errors.New("payment amount exceeds the remaining amount to pay")
	}

	// Create transaction
	transaction := models.Transaction{
		UnitLedgerID: unitExpense.UnitID,
		Amount:       amount,
		Description:  description,
		ConceptID:    conceptID,
		ExpenseID:    &unitExpense.ID,
	}

	createdTransaction, err := RecordTransaction(transaction)
	if err != nil {
		return models.Payment{}, err
	}

	// Create payment
	payment := models.Payment{
		Amount:        amount,
		Description:   description,
		UnitExpenseID: &unitExpenseID,
		TransactionID: createdTransaction.ID,
	}

	if err := config.DB.Create(&payment).Error; err != nil {
		return payment, err
	}

	// Update unit expense
	unitExpense.LeftToPay -= amount
	if unitExpense.LeftToPay == 0 {
		unitExpense.Paid = true
	}

	if err := config.DB.Save(&unitExpense).Error; err != nil {
		return payment, err
	}

	return payment, nil
}
