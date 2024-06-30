package services

import (
	"backend/config"
	"backend/models"
	"errors"
	"time"
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
func AutoPayUnitExpenses(unitID uint, amount float64, year int, month time.Month, conceptID uint) ([]models.Payment, error) {
	// Fetch all liquidated but not paid unit expenses for the given unit and specific period
	startOfMonth := time.Date(year, month, 1, 0, 0, 0, 0, time.UTC)
	endOfMonth := startOfMonth.AddDate(0, 1, 0).Add(-time.Nanosecond)

	var expenses []models.UnitExpense
	if err := config.DB.Joins("JOIN concepts ON unit_expenses.concept_id = concepts.id").
		Where("unit_expenses.unit_id = ? AND unit_expenses.liquidate_period BETWEEN ? AND ? AND unit_expenses.liquidated = ? AND unit_expenses.paid = ?", unitID, startOfMonth, endOfMonth, true, false).
		Order("concepts.priority").Find(&expenses).Error; err != nil {
		return nil, err
	}

	var payments []models.Payment
	var totalPaid float64
	remainingAmount := amount // Initialize remaining amount with the total amount passed

	// Iterate through expenses and pay them until the amount is exhausted
	for _, expense := range expenses {
		if remainingAmount <= 0 {
			break
		}

		// Calculate the remaining amount to pay for the current expense
		remainingToPay := expense.LeftToPay

		// Determine the amount to pay for this expense
		var paymentAmount float64
		if remainingAmount >= remainingToPay {
			paymentAmount = remainingToPay
		} else {
			paymentAmount = remainingAmount
		}

		// Create payment transaction
		transaction := models.Transaction{
			UnitLedgerID: unitID,
			Amount:       paymentAmount,
			Description:  "Pago de Expensa",
			ConceptID:    conceptID,
			ExpenseID:    &expense.ID,
		}

		createdTransaction, err := RecordTransaction(transaction)
		if err != nil {
			return payments, err
		}

		// Create payment
		payment := models.Payment{
			Amount:        paymentAmount,
			Description:   "Pago de Expensa",
			UnitExpenseID: &expense.ID,
			TransactionID: createdTransaction.ID,
		}

		if err := config.DB.Create(&payment).Error; err != nil {
			return payments, err
		}

		// Update unit expense
		expense.LeftToPay -= paymentAmount
		if expense.LeftToPay == 0 {
			expense.Paid = true
		}

		if err := config.DB.Save(&expense).Error; err != nil {
			return payments, err
		}

		// Add the payment to the list
		payments = append(payments, payment)
		totalPaid += paymentAmount
		remainingAmount -= paymentAmount // Reduce remaining amount after each payment
	}

	// If remaining amount is greater than 0, create a surplus transaction and payment
	if remainingAmount > 0 {
		// Create transaction for surplus amount to ledger
		surplusTransaction := models.Transaction{
			UnitLedgerID: unitID,
			Amount:       remainingAmount,
			Description:  "Saldo a Favor",
			ConceptID:    conceptID, // Use the same concept ID for surplus transaction
			ExpenseID:    nil,       // Set ExpenseID to nil or leave it out if not applicable
		}

		createdSurplusTransaction, err := RecordTransaction(surplusTransaction)
		if err != nil {
			return payments, err
		}

		// Create payment for surplus amount
		surplusPayment := models.Payment{
			Amount:        remainingAmount,
			Description:   "Pago de Sobrante",
			TransactionID: createdSurplusTransaction.ID,
		}

		if err := config.DB.Create(&surplusPayment).Error; err != nil {
			return payments, err
		}

		// Add the surplus payment to the payments list
		payments = append(payments, surplusPayment)
	}

	return payments, nil
}
