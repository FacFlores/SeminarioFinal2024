import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class UserDrawer extends StatefulWidget {
  final StorageService storageService;

  const UserDrawer({super.key, required this.storageService});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
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
                        'Bienvenido, ${user['name']} ${user['surname']}',
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
                      'Menu de Usuario',
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
            title: const Text('Dashboard'),
            onTap: () {
              context.go('/user');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments, color: AppTheme.accentColor),
            title: const Text('Expensas Pendientes'),
            onTap: () {
              context.go('/user/pending-expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded,
                color: AppTheme.accentColor),
            title: const Text('Comprobante de Expensas'),
            onTap: () {
              context.go('/user/documents/expensesPending');
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_present_outlined,
                color: AppTheme.accentColor),
            title: const Text('Documentos'),
            onTap: () {
              context.go('/user/documents');
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.notifications, color: AppTheme.accentColor),
            title: const Text('Notificaciones', style: AppTheme.textMedium),
            onTap: () {
              context.go('/user/notifications');
            },
          ),
                              ListTile(
            leading:
                const Icon(Icons.room_service_sharp, color: AppTheme.accentColor),
            title: const Text('Estado de Servicios', style: AppTheme.textMedium),
            onTap: () {
              context.go('/user/services');
            },
          ),
                    ListTile(
            leading:
                const Icon(Icons.calendar_month_outlined, color: AppTheme.accentColor),
            title: const Text('Reservas', style: AppTheme.textMedium),
            onTap: () {
              context.go('/user/reserves');
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
