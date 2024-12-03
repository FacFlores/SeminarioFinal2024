package services

import (
	"backend/config"
	"backend/models"
	"errors"
)

func CreateNotification(notification models.Notification) (models.Notification, error) {
	if err := config.DB.Create(&notification).Error; err != nil {
		return notification, err
	}
	return notification, nil
}

func GetNotificationsByUser(userID string) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Preload("SenderUser").
		Where("target_user_id = ?", userID).
		Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func GetNotificationsByTargetRole(role string) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Preload("SenderUser").
		Where("target_role = ?", role).
		Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func GetNotificationsByTargetUnit(unitID uint) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Preload("SenderUser").
		Where("target_unit_id = ?", unitID).
		Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func GetNotificationsByTargetConsortium(consortiumID uint) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := config.DB.Preload("SenderUser").
		Where("target_consortium_id = ?", consortiumID).
		Find(&notifications).Error; err != nil {
		return nil, err
	}
	return notifications, nil
}

func MarkNotificationAsRead(notificationID uint) error {
	var notification models.Notification
	if err := config.DB.First(&notification, notificationID).Error; err != nil {
		return errors.New("notification not found")
	}
	notification.IsRead = true
	if err := config.DB.Save(&notification).Error; err != nil {
		return err
	}
	return nil
}

func DeleteNotification(notificationID uint) error {
	if err := config.DB.Delete(&models.Notification{}, notificationID).Error; err != nil {
		return err
	}
	return nil
}
