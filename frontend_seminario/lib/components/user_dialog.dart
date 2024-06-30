import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class UserDialog extends StatefulWidget {
  final int? userId;
  final String? role;

  const UserDialog({super.key, this.userId, this.role});

  @override
  UserDialogState createState() => UserDialogState();
}

class UserDialogState extends State<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'User';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserData();
    } else {
      _role = widget.role ?? 'User';
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await UserApiService.getUserByID(widget.userId!);
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      setState(() {
        _nameController.text = user['name'];
        _surnameController.text = user['surname'];
        _emailController.text = user['email'];
        _phoneController.text = user['phone'];
        _dniController.text = user['dni'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dni': _dniController.text,
        if (widget.userId == null) 'role': _role,
        if (widget.userId == null) 'password': _passwordController.text,
      };
      Navigator.of(context).pop(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.userId == null ? 'Crear Usuario' : 'Editar Usuario'),
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
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un email';
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
                    if (widget.userId == null)
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: AppTheme.textSmall,
                          filled: true,
                          fillColor: AppTheme.lightBackground,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese contraseña';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                    const SizedBox(height: 16),
                    if (widget.userId == null)
                      DropdownButtonFormField<String>(
                        value: _role,
                        items: <String>['User', 'Admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: AppTheme.textSmall),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _role = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          labelStyle: AppTheme.textSmall,
                          filled: true,
                          fillColor: AppTheme.lightBackground,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
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
          onPressed: _saveUser,
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
