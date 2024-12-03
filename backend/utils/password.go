package utils

import (
	"regexp"

	"golang.org/x/crypto/bcrypt"
)

func IsValidPassword(password string) bool {
	var (
		hasMinLen  = len(password) >= 8
		hasNumber  = regexp.MustCompile(`[0-9]`).MatchString(password)
		hasUpper   = regexp.MustCompile(`[A-Z]`).MatchString(password)
		hasLower   = regexp.MustCompile(`[a-z]`).MatchString(password)
		hasSpecial = regexp.MustCompile(`[!@#\$%\^&\*\.\,\(\)\-\_\+\=\[\]\{\}\|\\;:\'\"<>\?/]`).MatchString(password)
	)
	return hasMinLen && hasNumber && hasUpper && hasLower && hasSpecial
}

func HashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

func CheckPasswordHash(password, hashedPassword string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
	return err == nil
}
