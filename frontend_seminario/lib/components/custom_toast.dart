import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend_seminario/components/custom_toast_widget.dart';

class CustomToast {
  static void show(String message, ToastType type, BuildContext context) {
    final fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: CustomToastWidget(message: message, type: type),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
