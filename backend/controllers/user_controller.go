package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func FindUsers(c *gin.Context) {
	users, err := services.GetAllUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, users)
}

func FindActiveUsers(c *gin.Context) {
	users, err := services.GetActiveUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, users)
}

func FindInactiveUsers(c *gin.Context) {
	users, err := services.GetDisabledUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, users)
}

func GetUserByID(c *gin.Context) {
	id := c.Param("id")

	user, err := services.GetUserByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, user)
}

func CreateUser(c *gin.Context) {
	var input struct {
		Name     string `json:"name" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Surname  string `json:"surname" binding:"required"`
		Phone    string `json:"phone" binding:"required"`
		Dni      string `json:"dni" binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userRole, err := services.GetRoleByName("User")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "User role not found"})
		return
	}

	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Surname:  input.Surname,
		Phone:    input.Phone,
		Dni:      input.Dni,
		RoleID:   userRole.ID,
		Password: input.Password,
		IsActive: false,
	}

	createdUser, err := services.CreateUser(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdUser)
}

func CreateAdmin(c *gin.Context) {
	var input struct {
		Name     string `json:"name" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Surname  string `json:"surname" binding:"required"`
		Phone    string `json:"phone" binding:"required"`
		Dni      string `json:"dni" binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	adminRole, err := services.GetRoleByName("Admin")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Admin role not found"})
		return
	}

	admin := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Surname:  input.Surname,
		Phone:    input.Phone,
		Dni:      input.Dni,
		RoleID:   adminRole.ID,
		Password: input.Password,
		IsActive: false,
	}

	createdAdmin, err := services.CreateUser(admin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, createdAdmin)
}

func Login(c *gin.Context) {
	var input struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, err := services.AuthenticateUser(input.Email, input.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}

func ToggleUserActiveStatus(c *gin.Context) {
	id := c.Param("id")

	user, err := services.GetUserByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	updatedUser, err := services.ToggleUserActiveStatus(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updatedUser)
}

func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	if err := services.DeleteUser(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "User deleted"})
}
