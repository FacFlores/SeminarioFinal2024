package services

import (
	"backend/config"
	"backend/models"
)

func CreateNotification(notification models.Notification) (models.Notification, error) {
	if err := config.DB.Create(&notification).Error; err != nil {
		return models.Notification{}, err
	}
	return notification, nil
}

func MarkNotificationAsRead(id uint) error {
	if err := config.DB.Model(&models.Notification{}).Where("id = ?", id).Update("is_read", true).Error; err != nil {
		return err
	}
	return nil
}

func DeleteNotification(id uint) error {
	if err := config.DB.Delete(&models.Notification{}, id).Error; err != nil {
		return err
	}
	return nil
}

func GetNotificationsByTargetRole(targetRole string) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Where("target_role = ?", targetRole).Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func GetNotificationsByTargetUnit(targetUnitID uint) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Where("target_unit_id = ?", targetUnitID).Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func GetNotificationsByTargetConsortium(targetConsortiumID uint) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Where("target_consortium_id = ?", targetConsortiumID).Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}
