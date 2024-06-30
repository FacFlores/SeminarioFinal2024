import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/coefficient_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class CoefficientDialog extends StatefulWidget {
  final int? coefficientId;

  const CoefficientDialog({super.key, this.coefficientId});

  @override
  CoefficientDialogState createState() => CoefficientDialogState();
}

class CoefficientDialogState extends State<CoefficientDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _distributable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.coefficientId != null) {
      _loadCoefficientData();
    }
  }

  Future<void> _loadCoefficientData() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await CoefficientApiService.getCoefficientById(widget.coefficientId!);
    if (response.statusCode == 200) {
      final coefficient = jsonDecode(response.body);
      setState(() {
        _nameController.text = coefficient['name'];
        _distributable = coefficient['distributable'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveCoefficient() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> coefficientData = {
        'name': _nameController.text,
        'distributable': _distributable,
      };
      Navigator.of(context).pop(coefficientData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.coefficientId == null
          ? 'Crear Coeficiente'
          : 'Editar Coeficiente'),
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
                        labelText: 'Nombre',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre para el coeficiente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Distribuible?',
                          style: AppTheme.textSmall),
                      value: _distributable,
                      onChanged: (bool? value) {
                        setState(() {
                          _distributable = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: AppTheme.textSmallBold),
        ),
        ElevatedButton(
          onPressed: _saveCoefficient,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Guardar', style: AppTheme.textSmallBold),
        ),
      ],
    );
  }
}
