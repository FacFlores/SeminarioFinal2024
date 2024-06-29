import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/admin_drawer.dart';
import 'package:frontend_seminario/components/user_drawer.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool isAdmin;
  final StorageService storageService;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.isAdmin,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: AppTheme.titleMedium.copyWith(color: AppTheme.accentColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.accentColor),
      ),
      drawer: isAdmin
          ? AdminDrawer(storageService: storageService)
          : UserDrawer(storageService: storageService),
      body: body,
    );
  }
}
