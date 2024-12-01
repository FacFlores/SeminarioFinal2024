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

	var concept models.Concept
	if err := config.DB.Preload("Coefficient").First(&concept, "id = ?", expense.ConceptID).Error; err != nil {
		return expense, errors.New("concept not found")
	}

	if !concept.Coefficient.Distributable {
		return expense, errors.New("only concepts with distributable true can be assigned")
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

func DistributeConsortiumExpense(expenseID uint) error {
	var expense models.ConsortiumExpense
	if err := config.DB.Preload("Concept.Coefficient").First(&expense, "id = ?", expenseID).Error; err != nil {
		return errors.New("consortium expense not found")
	}

	if expense.Distributed {
		return errors.New("expense has already been distributed")
	}

	var units []models.Unit
	if err := config.DB.Where("consortium_id = ?", expense.ConsortiumID).Find(&units).Error; err != nil {
		return errors.New("could not find units")
	}

	for _, unit := range units {
		var unitCoefficient models.UnitCoefficient
		if err := config.DB.Where("unit_id = ? AND coefficient_id = ?", unit.ID, expense.Concept.CoefficientID).First(&unitCoefficient).Error; err != nil {
			return errors.New("could not find unit coefficient")
		}

		amount := expense.Amount * unitCoefficient.Percentage / 100
		if amount == 0 {
			continue
		}

		unitExpense := models.UnitExpense{
			Description:         expense.Description,
			BillNumber:          expense.BillNumber,
			Amount:              amount,
			LeftToPay:           amount,
			ConceptID:           expense.ConceptID,
			ExpensePeriod:       expense.ExpensePeriod,
			LiquidatePeriod:     expense.LiquidatePeriod,
			Liquidated:          false,
			Paid:                false,
			UnitID:              unit.ID,
			ConsortiumExpenseID: &expense.ID,
		}

		if err := config.DB.Create(&unitExpense).Error; err != nil {
			return err
		}
	}

	expense.Distributed = true
	if err := config.DB.Save(&expense).Error; err != nil {
		return err
	}

	return nil
}

func GetConsortiumExpenseByID(id string) (models.ConsortiumExpense, error) {
	var expense models.ConsortiumExpense
	if err := config.DB.Preload("Concept").Preload("Consortium").First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}
	return expense, nil
}

func GetAllConsortiumExpenses() ([]models.ConsortiumExpense, error) {
	var expenses []models.ConsortiumExpense
	if err := config.DB.Preload("Concept").Preload("Consortium").Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}

func UpdateConsortiumExpense(id string, updatedData models.ConsortiumExpense) (models.ConsortiumExpense, error) {
	var expense models.ConsortiumExpense
	if err := config.DB.Preload("Concept").Preload("Consortium").First(&expense, "id = ?", id).Error; err != nil {
		return expense, err
	}

	if expense.Distributed {
		return expense, errors.New("cannot update a distributed expense")
	}

	expense.Description = updatedData.Description
	expense.Amount = updatedData.Amount
	expense.ConceptID = updatedData.ConceptID
	expense.ExpensePeriod = updatedData.ExpensePeriod
	expense.LiquidatePeriod = updatedData.LiquidatePeriod
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

func GetDistributedConsortiumExpensesByConsortium(consortiumID uint) ([]models.ConsortiumExpense, error) {
	var expenses []models.ConsortiumExpense
	if err := config.DB.Preload("Concept").Preload("Consortium").Where("distributed = ? AND consortium_id = ?", true, consortiumID).Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}

func GetNonDistributedConsortiumExpensesByConsortium(consortiumID uint) ([]models.ConsortiumExpense, error) {
	var expenses []models.ConsortiumExpense
	if err := config.DB.Preload("Concept").Preload("Consortium").Where("distributed = ? AND consortium_id = ?", false, consortiumID).Find(&expenses).Error; err != nil {
		return nil, err
	}
	return expenses, nil
}
