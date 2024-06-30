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
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.dashboard, color: AppTheme.accentColor),
              title: const Text(
                'Dashboard',
                style: AppTheme.textMedium,
              ),
              children: [
                ListTile(
                  title: const Text('Sub Menu 1', style: AppTheme.textSmall),
                  onTap: () {
                    context.go('/user-dashboard/submenu1');
                  },
                ),
                ListTile(
                  title: const Text('Sub Menu 2', style: AppTheme.textSmall),
                  onTap: () {
                    context.go('/user-dashboard/submenu2');
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.accentColor),
            title: const Text('Settings'),
            onTap: () {
              context.go('/user-settings');
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
