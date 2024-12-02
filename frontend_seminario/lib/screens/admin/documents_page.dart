import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/document_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';

class AdminDocumentsPage extends StatefulWidget {
  const AdminDocumentsPage({super.key});

  @override
  AdminDocumentsPageState createState() => AdminDocumentsPageState();
}

class AdminDocumentsPageState extends State<AdminDocumentsPage> {
  List<dynamic> documents = [];
  bool isLoading = false;
  String name = '';
  String documentType = 'application/pdf';
  String unitId = '';
  String consortiumId = '';
  PlatformFile? uploadedFile;
  List<dynamic> units = [];
  List<dynamic> consortiums = [];
  String? selectedUnit;
  String? selectedConsortium;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _fetchUnits();
    _fetchConsortiums();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await DocumentApiService.getAllDocuments();
      if (response.statusCode == 200) {
        setState(() {
          documents = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUnits() async {
    final response = await UnitApiService.getAllUnits();
    if (response.statusCode == 200) {
      setState(() {
        units = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      setState(() {
        consortiums = jsonDecode(response.body);
      });
    }
  }

  Future<void> _downloadDocument(int documentId, String documentName) async {
    try {
      final response = await DocumentApiService.serveDocument(documentId);
      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = '$documentName.pdf';

        anchor.click();

        html.Url.revokeObjectUrl(url);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el archivo')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    }
  }

  Future<void> _deleteDocument(int documentId) async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Este documento será eliminado permanentemente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); 
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await DocumentApiService.deleteDocument(documentId);
        if (response.statusCode == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento eliminado')),
          );
          _loadDocuments();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el documento')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

void _openAddDocumentModal() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    PlatformFile file = result.files.first;
    setState(() {
      uploadedFile = file;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Documento'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Nombre del documento',
                  labelStyle: AppTheme.textSmall,
                  filled: true,
                  fillColor: AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                hint: const Text('Seleccionar Unidad'),
                isExpanded: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                  });
                },
                items: units.map<DropdownMenuItem<String>>((unit) {
                  return DropdownMenuItem<String>(
                    value: unit['ID'].toString(),
                    child: Text(unit['name'] ?? 'Sin Nombre'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedConsortium,
                hint: const Text('Seleccionar Consorcio'),
                isExpanded: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedConsortium = newValue;
                  });
                },
                items: consortiums.map<DropdownMenuItem<String>>((consortium) {
                  return DropdownMenuItem<String>(
                    value: consortium['ID'].toString(),
                    child: Text(consortium['name'] ?? 'Sin Nombre'),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedUnit = null;
                  selectedConsortium = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _submitDocumentForm();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}


Future<void> _submitDocumentForm() async {
  if (name.isEmpty || uploadedFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, complete todos los campos')),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final response = await DocumentApiService.uploadDocument(
      name,
      selectedUnit,
      selectedConsortium,
      uploadedFile!,
    );
    if (response.statusCode == 200 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento agregado con éxito')),
      );
      _loadDocuments();

      setState(() {
        selectedUnit = null;
        selectedConsortium = null;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar el documento')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir el documento: $e')),
      );
    }
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Administrar Documentos',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _openAddDocumentModal,
              child: const Text('Agregar Documento'),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              final document = documents[index];
                              final unitName = document['Unit'] != null
                                  ? document['Unit']['name']
                                  : null;
                              final consortiumName =
                                  document['Consortium'] != null
                                      ? document['Consortium']['name']
                                      : null;
                              String subtitle = '';
                              if (unitName != null && consortiumName != null) {
                                subtitle = '$unitName - $consortiumName';
                              } else if (unitName != null) {
                                subtitle = unitName;
                              } else if (consortiumName != null) {
                                subtitle = consortiumName;
                              }

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    document['Name'] ?? 'Documento sin nombre',
                                    style: AppTheme.textMedium,
                                  ),
                                  subtitle: subtitle.isNotEmpty
                                      ? Text(
                                          subtitle,
                                          style: AppTheme.textSmall,
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () {
                                          _downloadDocument(
                                            document['ID'],
                                            document['Name'] ?? 'Documento',
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteDocument(document['ID']);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
          ],
        ),
      ),
      isAdmin: true,
      storageService: StorageService(),
    );
  }
}
