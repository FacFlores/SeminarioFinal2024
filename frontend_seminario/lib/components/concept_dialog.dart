import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/services/api/concept_api_service.dart';
import 'package:frontend_seminario/services/api/coefficient_api_service.dart';

class ConceptDialog extends StatefulWidget {
  final int? conceptId;

  const ConceptDialog({super.key, this.conceptId});

  @override
  ConceptDialogState createState() => ConceptDialogState();
}

class ConceptDialogState extends State<ConceptDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  String _origin = 'Debe';
  int? _priority = 1;
  int? _coefficientId;
  bool _isLoading = false;
  List<dynamic> _coefficients = [];

  @override
  void initState() {
    super.initState();
    if (widget.conceptId != null) {
      _loadConceptData();
    }
    _loadCoefficients();
  }

  Future<void> _loadConceptData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await ConceptApiService.getConceptById(widget.conceptId!);
    if (response.statusCode == 200) {
      final concept = jsonDecode(response.body);
      setState(() {
        _nameController.text = concept['name'];
        _descriptionController.text = concept['description'];
        _priority = concept['priority'];
        _origin = concept['origin'];
        _typeController.text = concept['type'];
        _coefficientId = concept['coefficientID'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCoefficients() async {
    final response = await CoefficientApiService.getAllCoefficients();
    if (response.statusCode == 200) {
      setState(() {
        _coefficients = jsonDecode(response.body);
      });
    }
  }

  void _saveConcept() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> conceptData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'priority': _priority,
        'origin': _origin,
        'type': _typeController.text,
        'coefficient_id': _coefficientId,
      };
      Navigator.of(context).pop(conceptData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.conceptId == null ? 'Create Concept' : 'Edit Concept'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _priority,
                      items: List.generate(10, (index) => index + 1)
                          .map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child:
                              Text(value.toString(), style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _priority = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Priority',
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
                      value: _origin,
                      items: <String>['Debe', 'Haber'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _origin = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Origin',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _coefficientId,
                      items: _coefficients
                          .map<DropdownMenuItem<int>>((coefficient) {
                        return DropdownMenuItem<int>(
                          value: coefficient['ID'],
                          child: Text(coefficient['name'],
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _coefficientId = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Coefficient',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a coefficient';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: AppTheme.textSmallBold),
        ),
        ElevatedButton(
          onPressed: _saveConcept,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Save', style: AppTheme.textSmallBold),
        ),
      ],
    );
  }
}
