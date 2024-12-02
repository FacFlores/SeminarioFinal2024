package controllers

import (
	"backend/services"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func UploadDocument(c *gin.Context) {
	var input struct {
		ConsortiumID *uint  `form:"consortium_id"`
		UnitID       *uint  `form:"unit_id"`
		DocumentType string `form:"document_type"`
		Name         string `form:"name" binding:"required"`
	}
	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	fmt.Printf("Received input: %+v\n", input)
	file, _, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file upload"})
		return
	}
	fmt.Println("File received:", file)
	document, err := services.UploadDocument(input.ConsortiumID, input.UnitID, input.DocumentType, input.Name, file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, document)
}

func GetDocumentsByConsortium(c *gin.Context) {
	consortiumID, err := strconv.Atoi(c.Param("consortium_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid consortium ID"})
		return
	}
	documents, err := services.GetDocumentsByConsortium(uint(consortiumID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, documents)
}
func GetDocumentsByUnit(c *gin.Context) {
	unitID, err := strconv.Atoi(c.Param("unit_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid unit ID"})
		return
	}
	documents, err := services.GetDocumentsByUnit(uint(unitID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, documents)
}

func GetDocumentByName(c *gin.Context) {
	documentName := c.Param("document_name")
	document, err := services.GetDocumentByName(documentName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, document)
}

func GetAllDocuments(c *gin.Context) {
	documents, err := services.GetAllDocuments()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, documents)
}

func DeleteDocumentByID(c *gin.Context) {
	documentID, err := strconv.Atoi(c.Param("document_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
		return
	}
	err = services.DeleteDocumentByID(uint(documentID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Document deleted successfully"})
}

func ServeDocument(c *gin.Context) {
	documentID, err := strconv.Atoi(c.Param("document_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
		return
	}

	document, err := services.GetDocumentByID(uint(documentID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Document not found"})
		return
	}

	file, err := os.Open(document.FilePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Unable to open document file"})
		return
	}
	defer file.Close()
	c.Header("Content-Type", "application/pdf")
	c.Header("Content-Disposition", "attachment; filename="+document.Name)
	http.ServeContent(c.Writer, c.Request, document.Name, time.Now(), file)
}
