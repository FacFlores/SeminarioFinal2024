package services

import (
	"backend/config"
	"backend/models"
	"time"
)

func CreateUnit(unit models.Unit) (models.Unit, error) {
	tx := config.DB.Begin()

	if err := tx.Create(&unit).Error; err != nil {
		tx.Rollback()
		return unit, err
	}

	unitLedger := models.UnitLedger{
		UnitID:  unit.ID,
		Balance: 0,
	}

	if err := tx.Create(&unitLedger).Error; err != nil {
		tx.Rollback()
		return unit, err
	}

	tx.Commit()

	return unit, nil
}

func DeleteUnit(id string) error {
	result := config.DB.Unscoped().Model(&models.Unit{}).Where("id = ?", id).Update("deleted_at", time.Now())
	if err := result.Error; err != nil {
		return err
	}

	return nil
}

func GetUnitByID(id uint) (models.Unit, error) {
	var unit models.Unit
	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").First(&unit, "id = ?", id).Error; err != nil {
		return unit, err
	}
	return unit, nil
}

func GetUnitByName(name string) (models.Unit, error) {
	var unit models.Unit
	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").Where("name = ?", name).Where("deleted_at IS NULL").First(&unit).Error; err != nil {
		return unit, err
	}
	return unit, nil
}

func GetAllUnits() ([]models.Unit, error) {
	var units []models.Unit
	result := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").Where("deleted_at IS NULL").Find(&units)

	if err := result.Error; err != nil {
		return nil, err
	}
	return units, nil
}

func UpdateUnit(id string, updatedData models.Unit) (models.Unit, error) {
	var unit models.Unit
	if err := config.DB.First(&unit, "id = ?", id).Error; err != nil {
		return unit, err
	}

	unit.Name = updatedData.Name
	unit.ConsortiumID = updatedData.ConsortiumID

	if err := config.DB.Save(&unit).Error; err != nil {
		return unit, err
	}

	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").First(&unit, "id = ?", id).Error; err != nil {
		return unit, err
	}

	return unit, nil
}

func GetOwnersByUnitID(unitID uint) ([]models.Owner, error) {
	var unit models.Unit
	if err := config.DB.Preload("Owners").First(&unit, unitID).Error; err != nil {
		return nil, err
	}
	return unit.Owners, nil
}

func GetRoomersByUnitID(unitID uint) ([]models.Roomer, error) {
	var unit models.Unit
	if err := config.DB.Preload("Roomers").First(&unit, unitID).Error; err != nil {
		return nil, err
	}
	return unit.Roomers, nil
}

func AssignOwnerToUnit(unitID, ownerID uint) (models.Unit, error) {
	var unit models.Unit
	var owner models.Owner

	if err := config.DB.First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.First(&owner, ownerID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.Model(&unit).Association("Owners").Append(&owner); err != nil {
		return unit, err
	}

	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	return unit, nil
}

func AssignRoomerToUnit(unitID, roomerID uint) (models.Unit, error) {
	var unit models.Unit
	var roomer models.Roomer

	if err := config.DB.First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.First(&roomer, roomerID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.Model(&unit).Association("Roomers").Append(&roomer); err != nil {
		return unit, err
	}

	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	return unit, nil
}

func RemoveOwnerFromUnit(unitID, ownerID uint) (models.Unit, error) {
	var unit models.Unit
	var owner models.Owner

	if err := config.DB.First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.First(&owner, ownerID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.Model(&unit).Association("Owners").Delete(&owner); err != nil {
		return unit, err
	}

	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	return unit, nil
}

func RemoveRoomerFromUnit(unitID, roomerID uint) (models.Unit, error) {
	var unit models.Unit
	var roomer models.Roomer

	if err := config.DB.First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.First(&roomer, roomerID).Error; err != nil {
		return unit, err
	}

	if err := config.DB.Model(&unit).Association("Roomers").Delete(&roomer); err != nil {
		return unit, err
	}

	if err := config.DB.Preload("Consortium").Preload("Owners").Preload("Roomers").First(&unit, unitID).Error; err != nil {
		return unit, err
	}

	return unit, nil
}

func GetUnitsByConsortium(consortiumID uint) ([]models.Unit, error) {
	var units []models.Unit
	if err := config.DB.Where("consortium_id = ?", consortiumID).Preload("Consortium").Preload("Owners").Preload("Roomers").Where("deleted_at IS NULL").Find(&units).Error; err != nil {
		return nil, err
	}
	return units, nil
}
