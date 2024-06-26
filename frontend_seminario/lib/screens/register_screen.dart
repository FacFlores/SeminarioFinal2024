import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api_service.dart';
import 'package:frontend_seminario/components/custom_form_field.dart';
import 'package:frontend_seminario/components/custom_button.dart';

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

  void _register() async {
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
        print('Registration successful');
      } else {
        print('Registration failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: constraints.maxWidth < 600
                  ? Column(
                      children: _buildFormFields(),
                    )
                  : Row(
                      children: _buildFormFields().map((field) {
                        return Expanded(child: field);
                      }).toList(),
                    ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return <Widget>[
      CustomFormField(
        controller: _nameController,
        labelText: 'Name',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
      CustomFormField(
        controller: _surnameController,
        labelText: 'Surname',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your surname';
          }
          return null;
        },
      ),
      CustomFormField(
        controller: _phoneController,
        labelText: 'Phone',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone';
          }
          return null;
        },
      ),
      CustomFormField(
        controller: _dniController,
        labelText: 'DNI',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your DNI';
          }
          return null;
        },
      ),
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
        text: 'Register',
        onPressed: _register,
      ),
    ];
  }
}
