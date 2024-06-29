package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreateUnit(c *gin.Context) {
	var input struct {
		Name         string `json:"name" binding:"required"`
		ConsortiumID uint   `json:"consortium_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	unit := models.Unit{
		Name:         input.Name,
		ConsortiumID: input.ConsortiumID,
	}

	createdUnit, err := services.CreateUnit(unit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdUnit)
}

func GetOwnersByUnitID(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	owners, err := services.GetOwnersByUnitID(uint(id))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, owners)
}

func GetRoomersByUnitID(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	roomers, err := services.GetRoomersByUnitID(uint(id))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, roomers)
}

func GetUnitByID(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	unit, err := services.GetUnitByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Unit not found"})
		return
	}

	c.JSON(http.StatusOK, unit)
}

func GetUnitByName(c *gin.Context) {
	var input struct {
		Name string `json:"name" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	unit, err := services.GetUnitByName(input.Name)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Unit not found"})
		return
	}

	c.JSON(http.StatusOK, unit)
}

func GetAllUnits(c *gin.Context) {
	units, err := services.GetAllUnits()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, units)
}

func UpdateUnit(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Name         string `json:"name"`
		ConsortiumID uint   `json:"consortium_id"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updatedUnit, err := services.UpdateUnit(id, models.Unit{
		Name:         input.Name,
		ConsortiumID: input.ConsortiumID,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedUnit)
}

func DeleteUnit(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteUnit(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Unit deleted"})
}

func AssignOwnerToUnit(c *gin.Context) {
	unitIDStr := c.Param("unit_id")
	ownerIDStr := c.Param("owner_id")

	unitID, err := strconv.ParseUint(unitIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	ownerID, err := strconv.ParseUint(ownerIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid owner ID"})
		return
	}

	unit, err := services.AssignOwnerToUnit(uint(unitID), uint(ownerID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, unit)
}

func AssignRoomerToUnit(c *gin.Context) {
	unitIDStr := c.Param("unit_id")
	roomerIDStr := c.Param("roomer_id")

	unitID, err := strconv.ParseUint(unitIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	roomerID, err := strconv.ParseUint(roomerIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid roomer ID"})
		return
	}

	unit, err := services.AssignRoomerToUnit(uint(unitID), uint(roomerID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, unit)
}

func RemoveOwnerFromUnit(c *gin.Context) {
	unitIDStr := c.Param("unit_id")
	ownerIDStr := c.Param("owner_id")

	unitID, err := strconv.ParseUint(unitIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	ownerID, err := strconv.ParseUint(ownerIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid owner ID"})
		return
	}

	unit, err := services.RemoveOwnerFromUnit(uint(unitID), uint(ownerID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, unit)
}

func RemoveRoomerFromUnit(c *gin.Context) {
	unitIDStr := c.Param("unit_id")
	roomerIDStr := c.Param("roomer_id")

	unitID, err := strconv.ParseUint(unitIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}

	roomerID, err := strconv.ParseUint(roomerIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid roomer ID"})
		return
	}

	unit, err := services.RemoveRoomerFromUnit(uint(unitID), uint(roomerID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, unit)
}

func GetUnitsByConsortium(c *gin.Context) {
	consortiumIDStr := c.Param("consortium_id")
	consortiumID, err := strconv.ParseUint(consortiumIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}

	units, err := services.GetUnitsByConsortium(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, units)
}
