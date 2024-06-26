import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppTheme.themeData.elevatedButtonTheme.style,
      child: Text(
        text,
        style: AppTheme.textBold,
      ),
    );
  }
}
