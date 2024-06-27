import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/components/custom_form_field.dart';
import 'package:frontend_seminario/components/custom_button.dart';
import 'package:frontend_seminario/theme.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final user = responseBody['user'];
        await StorageService().saveToken(token);
        await StorageService().saveUserData(user);
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  void _handleLogin() async {
    bool isLoggedIn = await _login();
    if (!mounted) return;

    if (isLoggedIn) {
      final user = await StorageService().getUserData();
      if (!mounted) return;
      if (user != null) {
        final role = user['role']['name'];
        if (role == 'Admin') {
          context.go('/admin-dashboard');
        } else {
          context.go('/user-dashboard');
        }
      }
    } else {
      // Handle failed login
      print('Login failed');
    }
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
                        Image.asset(
                          'assets/logo.png',
                          height: 100,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sistema de Gestión de Consorcios',
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
                          labelText: 'Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese una contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          CustomButton(
                            text: 'Login',
                            onPressed: _handleLogin,
                          ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              'No tienes una cuenta?',
                              style: AppTheme.textMedium,
                            ),
                            const SizedBox(width: 8),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  context.go('/register');
                                },
                                child: Text(
                                  'Registrate',
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
