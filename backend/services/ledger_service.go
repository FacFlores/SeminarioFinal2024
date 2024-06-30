package services

import (
	"backend/config"
	"backend/models"
	"errors"
	"time"
)

func RecordTransaction(transaction models.Transaction) (models.Transaction, error) {
	var ledger models.UnitLedger
	if err := config.DB.First(&ledger, "id = ?", transaction.UnitLedgerID).Error; err != nil {
		return transaction, err
	}

	var concept models.Concept
	if err := config.DB.First(&concept, "id = ?", transaction.ConceptID).Error; err != nil {
		return transaction, err
	}

	if transaction.ExpenseID != nil {
		var expense models.UnitExpense
		if err := config.DB.First(&expense, "id = ?", *transaction.ExpenseID).Error; err != nil {
			return transaction, err
		}
	}
	if concept.Origin == "Debe" {
		ledger.Balance -= transaction.Amount
	} else if concept.Origin == "Haber" {
		ledger.Balance += transaction.Amount
	} else {
		return transaction, errors.New("invalid concept origin type")
	}

	if err := config.DB.Save(&ledger).Error; err != nil {
		return transaction, err
	}

	if transaction.Date.IsZero() {
		transaction.Date = time.Now()
	}

	if err := config.DB.Create(&transaction).Error; err != nil {
		return transaction, err
	}

	return transaction, nil
}

func GetUnitBalance(unitID uint) (float64, error) {
	var ledger models.UnitLedger
	if err := config.DB.First(&ledger, "unit_id = ?", unitID).Error; err != nil {
		return 0, err
	}
	return ledger.Balance, nil
}

func GetUnitTransactions(unitID uint) ([]models.Transaction, error) {
	var transactions []models.Transaction
	if err := config.DB.Where("unit_ledger_id = ?", unitID).Order("date desc").Find(&transactions).Error; err != nil {
		return nil, err
	}
	return transactions, nil
}

func SoftDeleteUnitLedgerByUnitID(unitID uint) error {
	result := config.DB.Where("unit_id = ?", unitID).Delete(&models.UnitLedger{})
	return result.Error
}
