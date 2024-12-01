package services

import (
	"backend/config"
	"backend/models"
)

func GetDashboardSummary() (map[string]interface{}, error) {
	var totalUsers, activeUsers, inactiveUsers, totalConsortiums, unreadNotifications int64
	var totalFundsCollected, totalExpensesPending, totalPayments float64

	// Total Users
	if err := config.DB.Model(&models.User{}).Count(&totalUsers).Error; err != nil {
		return nil, err
	}

	// Active Users
	if err := config.DB.Model(&models.User{}).Where("is_active = ?", true).Count(&activeUsers).Error; err != nil {
		return nil, err
	}

	// Inactive Users
	if err := config.DB.Model(&models.User{}).Where("is_active = ?", false).Count(&inactiveUsers).Error; err != nil {
		return nil, err
	}

	// Total Consortiums
	if err := config.DB.Model(&models.Consortium{}).Count(&totalConsortiums).Error; err != nil {
		return nil, err
	}

	// Total Transactions
	if err := config.DB.Model(&models.Transaction{}).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalFundsCollected).Error; err != nil {
		return nil, err
	}

	// Total Expenses Pending
	if err := config.DB.Model(&models.UnitExpense{}).
		Select("COALESCE(SUM(left_to_pay), 0)").
		Where("paid = ?", false).
		Scan(&totalExpensesPending).Error; err != nil {
		return nil, err
	}

	// Total Payments
	if err := config.DB.Model(&models.Payment{}).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalPayments).Error; err != nil {
		return nil, err
	}

	// Unread Notifications
	if err := config.DB.Model(&models.Notification{}).Where("is_read = ?", false).Count(&unreadNotifications).Error; err != nil {
		return nil, err
	}

	summary := map[string]interface{}{
		"totalUsers":          totalUsers,
		"activeUsers":         activeUsers,
		"inactiveUsers":       inactiveUsers,
		"totalConsortiums":    totalConsortiums,
		"fundsCollected":      totalFundsCollected,
		"pendingExpenses":     totalExpensesPending,
		"payments":            totalPayments,
		"unreadNotifications": unreadNotifications,
	}

	return summary, nil
}

func GetUnitMetrics() ([]map[string]interface{}, error) {
	var units []models.Unit
	if err := config.DB.Preload("Owners").Preload("Roomers").Find(&units).Error; err != nil {
		return nil, err
	}

	var unitMetrics []map[string]interface{}

	for _, unit := range units {
		var balance, expensesPending float64
		if err := config.DB.Model(&models.UnitLedger{}).
			Select("balance").
			Where("unit_id = ?", unit.ID).
			Scan(&balance).Error; err != nil {
			return nil, err
		}
		err := config.DB.Model(&models.UnitExpense{}).
			Select("COALESCE(SUM(left_to_pay), 0)").
			Where("unit_id = ? AND paid = ?", unit.ID, false).
			Scan(&expensesPending).Error
		if err != nil {
			return nil, err
		}
		unitMetrics = append(unitMetrics, map[string]interface{}{
			"unitID":          unit.ID,
			"name":            unit.Name,
			"balance":         balance,
			"pendingExpenses": expensesPending,
			"ownersCount":     len(unit.Owners),
			"roomersCount":    len(unit.Roomers),
		})
	}

	return unitMetrics, nil
}

func GetConsortiumMetrics() ([]map[string]interface{}, error) {
	var consortiums []models.Consortium
	if err := config.DB.Preload("Units").Find(&consortiums).Error; err != nil {
		return nil, err
	}

	var consortiumMetrics []map[string]interface{}

	for _, consortium := range consortiums {
		var totalUnits, totalOwners, totalRoomers int64
		var fundsCollected, expensesPending float64
		if err := config.DB.Model(&models.Unit{}).Where("consortium_id = ?", consortium.ID).Count(&totalUnits).Error; err != nil {
			return nil, err
		}
		if err := config.DB.Model(&models.Owner{}).
			Joins("JOIN unit_owners ON unit_owners.owner_id = owners.id").
			Joins("JOIN units ON units.id = unit_owners.unit_id").
			Where("units.consortium_id = ?", consortium.ID).
			Count(&totalOwners).Error; err != nil {
			return nil, err
		}
		if err := config.DB.Model(&models.Roomer{}).
			Joins("JOIN unit_roomers ON unit_roomers.roomer_id = roomers.id").
			Joins("JOIN units ON units.id = unit_roomers.unit_id").
			Where("units.consortium_id = ?", consortium.ID).
			Count(&totalRoomers).Error; err != nil {
			return nil, err
		}
		if err := config.DB.Model(&models.Transaction{}).
			Select("COALESCE(SUM(amount), 0)").
			Joins("JOIN unit_ledgers ON unit_ledgers.id = transactions.unit_ledger_id").
			Joins("JOIN units ON units.id = unit_ledgers.unit_id").
			Where("units.consortium_id = ?", consortium.ID).
			Scan(&fundsCollected).Error; err != nil {
			return nil, err
		}
		if err := config.DB.Model(&models.UnitExpense{}).
			Select("COALESCE(SUM(left_to_pay), 0)").
			Joins("JOIN units ON units.id = unit_expenses.unit_id").
			Where("units.consortium_id = ? AND unit_expenses.paid = ?", consortium.ID, false).
			Scan(&expensesPending).Error; err != nil {
			return nil, err
		}
		consortiumMetrics = append(consortiumMetrics, map[string]interface{}{
			"consortiumID":    consortium.ID,
			"name":            consortium.Name,
			"totalUnits":      totalUnits,
			"totalOwners":     totalOwners,
			"totalRoomers":    totalRoomers,
			"fundsCollected":  fundsCollected,
			"pendingExpenses": expensesPending,
		})
	}

	return consortiumMetrics, nil
}
