import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/components/owner_dialog.dart';
import 'package:frontend_seminario/components/roomer_dialog.dart';
import 'package:frontend_seminario/services/api/owner_api_service.dart';
import 'package:frontend_seminario/services/api/roomer_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class OwnerRoomerManagementPage extends StatefulWidget {
  const OwnerRoomerManagementPage({super.key});

  @override
  OwnerRoomerManagementPageState createState() =>
      OwnerRoomerManagementPageState();
}

class OwnerRoomerManagementPageState extends State<OwnerRoomerManagementPage> {
  List<dynamic> owners = [];
  List<dynamic> roomers = [];

  @override
  void initState() {
    super.initState();
    _loadOwners();
    _loadRoomers();
  }

  Future<void> _loadOwners() async {
    final response = await OwnersApiService.getAllOwners();
    if (response.statusCode == 200) {
      setState(() {
        owners = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _loadRoomers() async {
    final response = await RoomerApiService.getAllRoomers();
    if (response.statusCode == 200) {
      setState(() {
        roomers = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  void _createOrUpdateOwner([int? ownerId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => OwnerDialog(ownerId: ownerId),
    );

    if (result != null) {
      final response = ownerId != null
          ? await OwnersApiService.editOwner(ownerId, result)
          : await OwnersApiService.createOwner(result);

      if (response.statusCode == 200) {
        _loadOwners(); 
      } else {
      }
    }
  }

  void _createOrUpdateRoomer([int? roomerId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RoomerDialog(roomerId: roomerId),
    );

    if (result != null) {
      final response = roomerId != null
          ? await RoomerApiService.editRoomer(roomerId, result)
          : await RoomerApiService.createRoomer(result);

      if (response.statusCode == 200) {
        _loadRoomers(); // Refresh list after update
      } else {
        // Handle errors
      }
    }
  }

  void _deleteOwner(int ownerId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea eliminar el propietario?'),
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
      final response = await OwnersApiService.deleteOwner(ownerId);
      if (response.statusCode == 200) {
        _loadOwners(); 
      } else {
      }
    }
  }

  void _deleteRoomer(int roomerId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea eliminar el inquilino?'),
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
      final response = await RoomerApiService.deleteRoomer(roomerId);
      if (response.statusCode == 200) {
        _loadRoomers(); 
      } else {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestion de Consorcistas',
      body: _buildManagementList(),
      isAdmin: true,
      storageService: StorageService(),
    );
  }

  Widget _buildManagementList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _createOrUpdateOwner(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.accentColor,
                ),
                child: const Text('Agregar Propietario'),
              ),
              ElevatedButton(
                onPressed: () => _createOrUpdateRoomer(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.accentColor,
                ),
                child: const Text('Agregar Inquilino'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Propietarios', style: AppTheme.textBold),
          Expanded(
            child: ListView.builder(
              itemCount: owners.length,
              itemBuilder: (context, index) {
                var owner = owners[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(owner['name'] + ' ' + owner['surname'], style: AppTheme.textMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Telefono: ${owner['phone']}',
                            style: AppTheme.textSmall),
                        Text('DNI: ${owner['dni']}', style: AppTheme.textSmall),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () => _createOrUpdateOwner(owner['ID']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () => _deleteOwner(owner['ID']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Inquilinos', style: AppTheme.textBold),
          Expanded(
            child: ListView.builder(
              itemCount: roomers.length,
              itemBuilder: (context, index) {
                var roomer = roomers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(roomer['name'] + ' ' + roomer['surname'], style: AppTheme.textMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Telefono: ${roomer['phone']}',
                            style: AppTheme.textSmall),
                        Text('DNI: ${roomer['dni']}',
                            style: AppTheme.textSmall),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () => _createOrUpdateRoomer(roomer['ID']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () => _deleteRoomer(roomer['ID']),
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
