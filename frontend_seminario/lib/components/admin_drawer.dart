// lib/components/admin_drawer.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class AdminDrawer extends StatefulWidget {
  final StorageService storageService;

  const AdminDrawer({super.key, required this.storageService});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  late Future<Map<String, dynamic>?> _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.storageService.getUserData();
  }

  Future<void> _logout() async {
    await widget.storageService.logout();
  }

  void _handleLogout() async {
    await _logout();
    if (mounted) {
      context.go('/login');
    }
  }

  Widget _buildProfilePicture(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return const Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 50,
      );
    } else {
      try {
        final imageBytes = base64Decode(base64Image.split(',')[1]);
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return const Icon(
          Icons.account_circle,
          color: Colors.white,
          size: 50,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasData) {
                final user = snapshot.data!;
                final profilePicture = user['profile_picture'];
                return DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProfilePicture(profilePicture),
                      const SizedBox(height: 10),
                      Text(
                        '${user['name']} ${user['surname']}',
                        style: AppTheme.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppTheme.accentColor),
            title: const Text('Dashboard', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_home_work_rounded,
                color: AppTheme.accentColor),
            title: const Text('Expensas', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined,
                color: AppTheme.accentColor),
            title: const Text('Liquidar', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/liquidations');
            },
          ),
          ExpansionTile(
            leading:
                const Icon(Icons.payments_sharp, color: AppTheme.accentColor),
            title: const Text('Pagos', style: AppTheme.textMedium),
            children: [
              ListTile(
                leading:
                    const Icon(Icons.handshake, color: AppTheme.accentColor),
                title: const Text('Pago Manual', style: AppTheme.textSmall),
                onTap: () {
                  context.go('/admin/payments/manual');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: AppTheme.accentColor),
                title: const Text('Pago Automatico', style: AppTheme.textSmall),
                onTap: () {
                  context.go('/admin/payments/automatic');
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.wallet,
                color: AppTheme.accentColor),
            title: const Text('Balance de Unidades', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/unit-balances');
            },
          ),
          ListTile(
            leading: const Icon(Icons.business, color: AppTheme.accentColor),
            title: const Text('Consorcios', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/consortiums');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_rounded,
                color: AppTheme.accentColor),
            title: const Text('Usuarios', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppTheme.accentColor),
            title: const Text('Consorcistas', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/people');
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.type_specimen, color: AppTheme.accentColor),
            title: const Text('Conceptos', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/concepts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.balance, color: AppTheme.accentColor),
            title: const Text('Coeficientes', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/coefficients');
            },
          ),
          ListTile(
            leading: const Icon(Icons.percent, color: AppTheme.accentColor),
            title:
                const Text('Asignar Porcentajes', style: AppTheme.textMedium),
            onTap: () {
              context.go('/admin/unit-coefficients');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.accentColor),
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}
