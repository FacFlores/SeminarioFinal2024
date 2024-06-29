package controllers

import (
	"backend/models"
	"backend/services"
	"io/ioutil"
	"net/http"

	"github.com/gin-gonic/gin"
)

// UploadDocument creates and stores a PDF document
func UploadDocument(c *gin.Context) {
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File upload failed"})
		return
	}
	defer file.Close()

	content, err := ioutil.ReadAll(file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read uploaded file"})
		return
	}

	// Example: You can extract visibility from the request or determine it based on the user's role
	visibility := c.PostForm("visibility")

	// Create document model instance
	document := models.Document{
		Name:        header.Filename,
		ContentType: header.Header.Get("Content-Type"),
		Content:     content,
		Visibility:  visibility,
	}

	// Save the document
	savedDocument, err := services.CreateDocument(document)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save document"})
		return
	}

	c.JSON(http.StatusOK, savedDocument)
}

// GetDocumentByID retrieves a document by its ID
func GetDocumentByID(c *gin.Context) {
	id := c.Param("id")

	document, err := services.GetDocumentByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Document not found"})
		return
	}

	// Serve the document content as a downloadable file
	c.Header("Content-Disposition", "attachment; filename="+document.Name)
	c.Data(http.StatusOK, document.ContentType, document.Content)
}
