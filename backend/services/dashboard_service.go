package services

import (
	"backend/config"
	"backend/models"
)

func GetAdminDashboardData() (map[string]interface{}, error) {
	var (
		totalExpenses, totalIncome, totalPendingExpenses float64
		expenseByMonth, incomeByMonth                    []map[string]interface{}
		consortiumSummary                                []map[string]interface{}
	)

	if err := config.DB.Model(&models.UnitExpense{}).
		Select("COALESCE(SUM(unit_expenses.amount), 0)").
		Where("liquidated = ?", true).
		Scan(&totalExpenses).Error; err != nil {
		return nil, err
	}

	if err := config.DB.Model(&models.Payment{}).
		Select("COALESCE(SUM(payments.amount), 0)").
		Scan(&totalIncome).Error; err != nil {
		return nil, err
	}

	if err := config.DB.Model(&models.UnitExpense{}).
		Select("COALESCE(SUM(unit_expenses.left_to_pay), 0)").
		Where("paid = ? AND liquidated = ?", false, true).
		Scan(&totalPendingExpenses).Error; err != nil {
		return nil, err
	}

	if err := config.DB.Table("unit_expenses").
		Select("DATE_TRUNC('month', unit_expenses.expense_period) AS month, COALESCE(SUM(unit_expenses.amount), 0) AS total").
		Where("unit_expenses.liquidated = ?", true).
		Group("month").
		Order("month").
		Find(&expenseByMonth).Error; err != nil {
		return nil, err
	}

	if err := config.DB.Table("payments").
		Select("DATE_TRUNC('month', payments.created_at) AS month, COALESCE(SUM(payments.amount), 0) AS total").
		Group("month").
		Order("month").
		Find(&incomeByMonth).Error; err != nil {
		return nil, err
	}

	rows, err := config.DB.Table("units").
		Select(`
			consortiums.id AS consortiumID,
			consortiums.name AS consortiumName,
			units.id AS unitID,
			units.name AS unitName,
			unit_ledgers.balance AS balance,
			COALESCE(SUM(unit_expenses.amount), 0) AS totalExpenses,
			COALESCE(SUM(unit_expenses.left_to_pay), 0) AS pendingExpenses,
			(SELECT COUNT(*) FROM unit_owners WHERE unit_owners.unit_id = units.id) AS ownersCount,
			(SELECT COUNT(*) FROM unit_roomers WHERE unit_roomers.unit_id = units.id) AS roomersCount
		`).
		Joins("JOIN consortiums ON consortiums.id = units.consortium_id").
		Joins("LEFT JOIN unit_ledgers ON unit_ledgers.unit_id = units.id").
		Joins("LEFT JOIN unit_expenses ON unit_expenses.unit_id = units.id AND unit_expenses.liquidated = true").
		Group("consortiums.id, consortiums.name, units.id, unit_ledgers.balance").
		Order("consortiums.id").
		Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	consortiumMap := make(map[uint]map[string]interface{})
	for rows.Next() {
		var (
			consortiumID, unitID                              uint
			consortiumName, unitName                          string
			balance, totalExpenses, pendingExpenses           float64
			ownersCount, roomersCount                         int64
			unitExpenseByMonth, unitIncomeByMonth             []map[string]interface{}
			consortiumExpenseByMonth, consortiumIncomeByMonth []map[string]interface{}
		)

		if err := rows.Scan(&consortiumID, &consortiumName, &unitID, &unitName, &balance, &totalExpenses, &pendingExpenses, &ownersCount, &roomersCount); err != nil {
			return nil, err
		}

		if err := config.DB.Table("unit_expenses").
			Select("DATE_TRUNC('month', unit_expenses.expense_period) AS month, COALESCE(SUM(unit_expenses.amount), 0) AS total").
			Where("unit_expenses.unit_id = ? AND unit_expenses.liquidated = ?", unitID, true).
			Group("month").
			Order("month").
			Find(&unitExpenseByMonth).Error; err != nil {
			return nil, err
		}

		if err := config.DB.Table("payments").
			Select("DATE_TRUNC('month', payments.created_at) AS month, COALESCE(SUM(payments.amount), 0) AS total").
			Where("unit_expense_id IN (SELECT id FROM unit_expenses WHERE unit_id = ? AND liquidated = true)", unitID).
			Group("month").
			Order("month").
			Find(&unitIncomeByMonth).Error; err != nil {
			return nil, err
		}

		unitData := map[string]interface{}{
			"unitID":          unitID,
			"name":            unitName,
			"balance":         balance,
			"totalExpenses":   totalExpenses,
			"pendingExpenses": pendingExpenses,
			"ownersCount":     ownersCount,
			"roomersCount":    roomersCount,
			"expenseByMonth":  unitExpenseByMonth,
			"incomeByMonth":   unitIncomeByMonth,
		}

		if err := config.DB.Table("unit_expenses").
			Select("DATE_TRUNC('month', unit_expenses.expense_period) AS month, COALESCE(SUM(unit_expenses.amount), 0) AS total").
			Joins("JOIN units ON units.id = unit_expenses.unit_id").
			Where("units.consortium_id = ? AND unit_expenses.liquidated = ?", consortiumID, true).
			Group("month").
			Order("month").
			Find(&consortiumExpenseByMonth).Error; err != nil {
			return nil, err
		}

		if err := config.DB.Table("payments").
			Select("DATE_TRUNC('month', payments.created_at) AS month, COALESCE(SUM(payments.amount), 0) AS total").
			Joins("JOIN unit_expenses ON unit_expenses.id = payments.unit_expense_id").
			Joins("JOIN units ON units.id = unit_expenses.unit_id").
			Where("units.consortium_id = ? AND unit_expenses.liquidated = ?", consortiumID, true).
			Group("month").
			Order("month").
			Find(&consortiumIncomeByMonth).Error; err != nil {
			return nil, err
		}

		if consortiumMap[consortiumID] == nil {
			consortiumMap[consortiumID] = map[string]interface{}{
				"consortiumID":    consortiumID,
				"name":            consortiumName,
				"balance":         0.0,
				"totalExpenses":   0.0,
				"pendingExpenses": 0.0,
				"expenseByMonth":  consortiumExpenseByMonth,
				"incomeByMonth":   consortiumIncomeByMonth,
				"units":           []map[string]interface{}{},
			}
		}

		consortiumMap[consortiumID]["units"] = append(
			consortiumMap[consortiumID]["units"].([]map[string]interface{}),
			unitData,
		)

		consortiumMap[consortiumID]["balance"] = consortiumMap[consortiumID]["balance"].(float64) + balance
		consortiumMap[consortiumID]["totalExpenses"] = consortiumMap[consortiumID]["totalExpenses"].(float64) + totalExpenses
		consortiumMap[consortiumID]["pendingExpenses"] = consortiumMap[consortiumID]["pendingExpenses"].(float64) + pendingExpenses
	}

	for _, consortium := range consortiumMap {
		consortiumSummary = append(consortiumSummary, consortium)
	}

	response := map[string]interface{}{
		"summary": map[string]interface{}{
			"totalExpenses":        totalExpenses,
			"totalIncome":          totalIncome,
			"totalPendingExpenses": totalPendingExpenses,
		},
		"graphData": map[string]interface{}{
			"expenseByMonth": expenseByMonth,
			"incomeByMonth":  incomeByMonth,
		},
		"consortiumSummary": consortiumSummary,
	}

	return response, nil
}
