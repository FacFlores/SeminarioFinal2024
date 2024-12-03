package services

import (
	"backend/config"
	"backend/models"
	"errors"
	"fmt"
	"time"
)

func GetAllReservations(consortiumID uint) ([]models.Reservation, error) {
	var reservations []models.Reservation
	if err := config.DB.Preload("Space").Where("consortium_id = ?", consortiumID).Find(&reservations).Error; err != nil {
		return nil, err
	}
	return reservations, nil
}

func GetReservationHistory(consortiumID uint) ([]models.Reservation, error) {
	var reservations []models.Reservation
	if err := config.DB.Preload("Space").Where("consortium_id = ? AND reservation_date < ?", consortiumID, time.Now().Format("2006-01-02")).Find(&reservations).Error; err != nil {
		return nil, err
	}
	return reservations, nil
}

func DeleteReservation(reservationID uint) error {
	var reservation models.Reservation

	if err := config.DB.First(&reservation, reservationID).Error; err != nil {
		return errors.New("reservation not found")
	}
	if err := config.DB.Delete(&reservation).Error; err != nil {
		return fmt.Errorf("could not delete reservation: %v", err)
	}
	return nil
}

func CreateReservation(reservation *models.Reservation) error {
	var space models.Space
	if err := config.DB.First(&space, reservation.SpaceID).Error; err != nil {
		return errors.New("space not found")
	}

	operationalStartTime, err := time.Parse("15:04", space.OperationalStartTime)
	if err != nil {
		return fmt.Errorf("invalid operational start time: %v", err)
	}
	operationalEndTime, err := time.Parse("15:04", space.OperationalEndTime)
	if err != nil {
		return fmt.Errorf("invalid operational end time: %v", err)
	}

	reservationStartTime, err := time.Parse("15:04", reservation.StartTime)
	if err != nil {
		return fmt.Errorf("invalid reservation start time: %v", err)
	}
	reservationEndTime, err := time.Parse("15:04", reservation.EndTime)
	if err != nil {
		return fmt.Errorf("invalid reservation end time: %v", err)
	}

	if reservationStartTime.Before(operationalStartTime) || reservationEndTime.After(operationalEndTime) {
		return errors.New("reservation time is outside of the space's operational hours")
	}

	var overlappingReservations []models.Reservation
	if err := config.DB.Where("space_id = ? AND reservation_date = ? AND ((start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?))",
		reservation.SpaceID, reservation.ReservationDate, reservationEndTime.Format("15:04"), reservationStartTime.Format("15:04"), reservationStartTime.Format("15:04"), reservationStartTime.Format("15:04")).
		Find(&overlappingReservations).Error; err != nil {
		return err
	}

	if len(overlappingReservations) > 0 {
		return errors.New("the space is already reserved during the selected time")
	}

	if err := config.DB.Create(reservation).Error; err != nil {
		return err
	}

	return nil
}
