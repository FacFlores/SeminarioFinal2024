import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return BaseScaffold(
      title: 'Admin Settings',
      body: const Center(
        child: Text(
          'Admin Settings Page',
          style: AppTheme.textMedium,
        ),
      ),
      isAdmin: true,
      storageService: storageService,
    );
  }
}
