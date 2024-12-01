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
	if err := config.DB.Where("consortium_id = ? AND deleted_at IS NULL", consortiumID).Find(&consortiumUnits).Error; err != nil {
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
	if err := config.DB.Where("coefficient_id = ? AND unit_id IN (SELECT id FROM units WHERE consortium_id = ?)", coefficientID, consortiumID).Delete(&models.UnitCoefficient{}).Error; err != nil {
		return nil, err
	}
	var updatedPercentages []models.UnitCoefficient
	for _, up := range unitPercentages {
		up.CoefficientID = coefficientID
		if err := config.DB.Create(&up).Error; err != nil {
			return nil, err
		}
		updatedPercentages = append(updatedPercentages, up)
	}
	return updatedPercentages, nil
}

func GetUnitsWithCoefficientsByConsortiumAndCoefficient(consortiumID, coefficientID uint) ([]map[string]interface{}, error) {
	var units []models.Unit
	if err := config.DB.
		Preload("Coefficients", "coefficient_id = ?", coefficientID).
		Where("consortium_id = ?", consortiumID).
		Find(&units).Error; err != nil {
		return nil, err
	}

	var result []map[string]interface{}
	for _, unit := range units {
		for _, coefficient := range unit.Coefficients {
			info := map[string]interface{}{
				"unit_id":        unit.ID,
				"unit_name":      unit.Name,
				"coefficient_id": coefficient.CoefficientID,
				"percentage":     coefficient.Percentage,
			}
			result = append(result, info)
		}
	}

	return result, nil
}
