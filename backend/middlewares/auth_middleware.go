package middlewares

import (
	"backend/config"
	"backend/models"
	"backend/utils"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
)

var jwtSecret []byte

func init() {
	utils.LoadEnv()
	jwtSecret = []byte(utils.GetEnv("JWT_SECRET", "42694193"))
}
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization header format"})
			c.Abort()
			return
		}

		claims := &jwt.StandardClaims{}

		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtSecret, nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		// Retrieve user information from the database and set it in the context
		var user models.User
		if err := config.DB.Preload("Role").First(&user, "id = ?", claims.Subject).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
			c.Abort()
			return
		}

		c.Set("user", user)
		c.Next()
	}
}

// Checks if the user has admin role
func AdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		user, exists := c.Get("user")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			c.Abort()
			return
		}

		if user.(models.User).Role.Name != "Admin" {
			c.JSON(http.StatusForbidden, gin.H{"error": "User is not an admin"})
			c.Abort()
			return
		}

		c.Next()
	}
}

// Checks if the user has owner, roomer or admin role
func UserMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		user, exists := c.Get("user")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			c.Abort()
			return
		}

		role := user.(models.User).Role.Name
		if role != "User" && role != "Admin" {
			c.JSON(http.StatusForbidden, gin.H{"error": "User does not have the necessary role"})
			c.Abort()
			return
		}

		c.Next()
	}
}

// GenerateToken generates a new JWT token for a given user ID
func GenerateToken(userID uint) (string, error) {
	claims := &jwt.StandardClaims{
		Subject:   strconv.FormatUint(uint64(userID), 10),
		ExpiresAt: time.Now().Add(24 * time.Hour).Unix(),
		IssuedAt:  time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}
