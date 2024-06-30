import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/components/user_dialog.dart';
import 'package:frontend_seminario/components/assign_owner_roomer_dialog.dart';
import 'package:frontend_seminario/services/api/admin_api_service.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:http/http.dart' as http;

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  UserManagementPageState createState() => UserManagementPageState();
}

class UserManagementPageState extends State<UserManagementPage> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final response = await UserApiService.getAllUsers();
    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
      });
    } else {}
  }

  void _createOrUpdateUser([int? userId, String? role]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UserDialog(userId: userId, role: role),
    );

    if (result != null) {
      late final http.Response response;
      if (userId == null) {
        response = result['role'] == 'Admin'
            ? await AdminApiService.registerAdmin(result)
            : await UserApiService.registerUser(result);
      } else {
        response = await UserApiService.updateUser(result, userId);
      }

      if (response.statusCode == 200) {
        _loadUsers();
      } else {}
    }
  }

  void _deleteUser(int userId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea borrar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: AppTheme.textSmall),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar', style: AppTheme.textSmallBold),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await AdminApiService.deleteUser(userId);
      if (response.statusCode == 200) {
        _loadUsers();
      } else {}
    }
  }

  void _toggleUserStatus(int userId, bool isActive) async {
    final response = await AdminApiService.toggleUserStatus(
        userId, {'is_active': !isActive});
    if (response.statusCode == 200) {
      _loadUsers();
    } else {}
  }

  void _assignOwnerRoomer(int userId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AssignOwnerRoomerDialog(userId: userId),
    );
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestion de Usuarios',
      body: _buildUserList(),
      isAdmin: true,
      storageService: StorageService(),
    );
  }

  Widget _buildUserList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _createOrUpdateUser(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Agregar Usuario'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                final isActive = user['is_active'] ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('${user['name']} ${user['surname']}',
                        style: AppTheme.textMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${user['email']}',
                            style: AppTheme.textSmall),
                        Text('Rol: ${user['role']['name']}',
                            style: AppTheme.textSmall),
                        Text('Estado: ${isActive ? 'Active' : 'Inactive'}',
                            style: AppTheme.textSmall),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            isActive ? Icons.toggle_on : Icons.toggle_off,
                            color: isActive
                                ? AppTheme.successColor
                                : AppTheme.dangerColor,
                          ),
                          onPressed: () =>
                              _toggleUserStatus(user['ID'], isActive),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person,
                              color: AppTheme.infoColor),
                          onPressed: () => _assignOwnerRoomer(user['ID']),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () => _createOrUpdateUser(
                              user['ID'], user['role']['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () => _deleteUser(user['ID']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
