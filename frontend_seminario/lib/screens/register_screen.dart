import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend_seminario/services/api_service.dart';
import 'package:frontend_seminario/components/custom_form_field.dart';
import 'package:frontend_seminario/components/custom_button.dart';
import 'package:frontend_seminario/theme.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dniController = TextEditingController();

  String? _passwordError;
  bool _isPasswordDirty = false;

  void _register() async {
    setState(() {
      _isPasswordDirty = true;
    });
    if (_formKey.currentState!.validate()) {
      final response = await ApiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _surnameController.text,
        _phoneController.text,
        _dniController.text,
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Registro exitoso',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        context.go('/login');
      } else {
        Fluttertoast.showToast(
          msg: 'Error ${response.statusCode}: ${response.body}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'La contraseña debe incluir al menos una letra mayúscula';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'La contraseña debe incluir al menos una letra minúscula';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'La contraseña debe incluir al menos un número';
    }
    if (!RegExp(
            r'(?=.*[!@#\$%\^&\*\.\,\(\)\-\_\+\=\[\]\{\}\|\\;:\\"<>\?\/\x27])')
        .hasMatch(value)) {
      return 'La contraseña debe incluir al menos un carácter especial';
    }

    return null;
  }

  void _checkPasswordValidation(String value) {
    setState(() {
      _passwordError = _validatePassword(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width =
                    constraints.maxWidth < 600 ? double.infinity : 600;
                return Container(
                  width: width,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Registro de Usuario',
                          style: AppTheme.titleMedium,
                        ),
                        const SizedBox(height: 20),
                        CustomFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomFormField(
                          controller: _passwordController,
                          labelText: 'Contraseña',
                          obscureText: true,
                          validator: (value) {
                            if (!_isPasswordDirty) {
                              return _validatePassword(value);
                            }
                            return null;
                          },
                          onChanged: _checkPasswordValidation,
                        ),
                        if (_isPasswordDirty && _passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomFormField(
                                controller: _nameController,
                                labelText: 'Nombre',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese un nombre';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomFormField(
                                controller: _surnameController,
                                labelText: 'Apellido',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese un apellido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomFormField(
                                controller: _dniController,
                                labelText: 'DNI',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese un DNI';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomFormField(
                                controller: _phoneController,
                                labelText: 'Telefono',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese un teléfono';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Solicitar Registro',
                          onPressed: _register,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ya tienes una cuenta?',
                              style: AppTheme.textMedium,
                            ),
                            const SizedBox(width: 8),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  context.go('/login');
                                },
                                child: Text(
                                  'Login',
                                  style: AppTheme.textBold.copyWith(
                                    color: AppTheme.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
