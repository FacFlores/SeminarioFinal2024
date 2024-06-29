import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return BaseScaffold(
      title: 'User Dashboard',
      body: const Center(
        child: Text(
          'Welcome to the User Dashboard',
          style: AppTheme.textMedium,
        ),
      ),
      isAdmin: false,
      storageService: storageService,
    );
  }
}
