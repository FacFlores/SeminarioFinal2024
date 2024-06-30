import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/roomer_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class RoomerDialog extends StatefulWidget {
  final int? roomerId;

  const RoomerDialog({super.key, this.roomerId});

  @override
  RoomerDialogState createState() => RoomerDialogState();
}

class RoomerDialogState extends State<RoomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _cuitController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.roomerId != null) {
      _loadRoomerData();
    }
  }

  Future<void> _loadRoomerData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await RoomerApiService.getRoomerById(widget.roomerId!);
    if (response.statusCode == 200) {
      final roomer = jsonDecode(response.body);
      setState(() {
        _nameController.text = roomer['name'];
        _surnameController.text = roomer['surname'];
        _phoneController.text = roomer['phone'];
        _dniController.text = roomer['dni'];
        _cuitController.text = roomer['cuit'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveRoomer() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> roomerData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'phone': _phoneController.text,
        'dni': _dniController.text,
        'cuit': _cuitController.text,
      };
      Navigator.of(context).pop(roomerData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.roomerId == null ? 'Cargar Inquilino' : 'Editar Inquilino'),
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
                          return 'Ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefono',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un numero de telefono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dniController,
                      decoration: const InputDecoration(
                        labelText: 'DNI',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un DNI';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cuitController,
                      decoration: const InputDecoration(
                        labelText: 'CUIT',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un CUIT';
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
          child: const Text('Cancelar', style: AppTheme.textSmallBold),
        ),
        ElevatedButton(
          onPressed: _saveRoomer,
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
