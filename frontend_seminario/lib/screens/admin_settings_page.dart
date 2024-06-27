// lib/screens/admin_settings_page.dart
import 'package:flutter/material.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: const Center(
        child: Text('Welcome to the Admin Settings Page'),
      ),
    );
  }
}
