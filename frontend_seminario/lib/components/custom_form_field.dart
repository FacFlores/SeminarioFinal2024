import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTheme.textMedium,
        filled: true,
        fillColor: AppTheme.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      style: AppTheme.textMedium,
      onChanged: onChanged,
    );
  }
}
