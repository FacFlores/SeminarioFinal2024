package services

import (
	"backend/config"
	"backend/models"
	"errors"
)

func UpdateUnitCoefficients(coefficientID uint, consortiumID uint, unitPercentages []models.UnitCoefficient) ([]models.UnitCoefficient, error) {
	var totalPercentage float64

	var coefficient models.Coefficient
	if err := config.DB.First(&coefficient, coefficientID).Error; err != nil {
		return nil, err
	}
	if !coefficient.Distributable {
		return nil, errors.New("the coefficient is not distributable")
	}

	var consortiumUnits []models.Unit
	if err := config.DB.Where("consortium_id = ?", consortiumID).Find(&consortiumUnits).Error; err != nil {
		return nil, err
	}

	consortiumUnitMap := make(map[uint]bool)
	for _, unit := range consortiumUnits {
		consortiumUnitMap[unit.ID] = true
	}

	for _, up := range unitPercentages {
		totalPercentage += up.Percentage

		var unit models.Unit
		if err := config.DB.First(&unit, up.UnitID).Error; err != nil {
			return nil, err
		}

		if unit.ConsortiumID != consortiumID {
			return nil, errors.New("all units must belong to the specified consortium")
		}

		delete(consortiumUnitMap, up.UnitID)
	}

	if len(consortiumUnitMap) > 0 {
		return nil, errors.New("not all units of the consortium are included in the request")
	}

	if totalPercentage != 100 {
		return nil, errors.New("total percentage for all units must be 100%")
	}

	if err := config.DB.Where("coefficient_id = ? AND consortium_id = ?", coefficientID, consortiumID).Delete(&models.UnitCoefficient{}).Error; err != nil {
		return nil, err
	}

	for _, up := range unitPercentages {
		up.CoefficientID = coefficientID
		if err := config.DB.Create(&up).Error; err != nil {
			return nil, err
		}
	}

	return unitPercentages, nil
}
