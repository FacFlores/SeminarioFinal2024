import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return BaseScaffold(
      title: 'Admin Dashboard',
      body: const Center(
        child: Text(
          'Welcome to the Admin Dashboard',
          style: AppTheme.textMedium,
        ),
      ),
      isAdmin: true,
      storageService: storageService,
    );
  }
}
