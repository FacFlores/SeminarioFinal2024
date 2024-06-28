import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';

enum ToastType { info, error, warning, success }

class CustomToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;

  const CustomToastWidget({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    switch (type) {
      case ToastType.info:
        backgroundColor = AppTheme.infoColor;
        break;
      case ToastType.error:
        backgroundColor = AppTheme.dangerColor;
        break;
      case ToastType.warning:
        backgroundColor = AppTheme.alertColor;
        break;
      case ToastType.success:
        backgroundColor = AppTheme.successColor;
        break;

      default:
        backgroundColor = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        message,
        style: AppTheme.textMedium.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
