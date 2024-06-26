import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/components/custom_form_field.dart';
import 'package:frontend_seminario/components/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _login() async {
    if (_formKey.currentState!.validate()) {
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

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
        print('User role: $role');
        if (role == 'Admin') {
          Navigator.pushNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushNamed(context, '/user-dashboard');
        }
        print('Login successful');
      } else {
        print('User data is null');
      }
    } else {
      // Handle failed login
      print('Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              CustomFormField(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              CustomFormField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Login',
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
