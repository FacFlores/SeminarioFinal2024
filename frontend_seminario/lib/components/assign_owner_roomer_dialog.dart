import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/owner_api_service.dart';
import 'package:frontend_seminario/services/api/roomer_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class AssignOwnerRoomerDialog extends StatefulWidget {
  final int userId;

  const AssignOwnerRoomerDialog({super.key, required this.userId});

  @override
  AssignOwnerRoomerDialogState createState() => AssignOwnerRoomerDialogState();
}

class AssignOwnerRoomerDialogState extends State<AssignOwnerRoomerDialog> {
  List<dynamic> currentOwners = [];
  List<dynamic> currentRoomers = [];
  List<dynamic> availableOwners = [];
  List<dynamic> availableRoomers = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentOwners();
    _loadCurrentRoomers();
    _loadAvailableOwners();
    _loadAvailableRoomers();
  }

  Future<void> _loadCurrentOwners() async {
    final response = await OwnersApiService.getOwnersByUser(widget.userId);
    if (response.statusCode == 200) {
      setState(() {
        currentOwners = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _loadCurrentRoomers() async {
    final response = await RoomerApiService.getRoomersByUser(widget.userId);
    if (response.statusCode == 200) {
      setState(() {
        currentRoomers = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _loadAvailableOwners() async {
    final response = await OwnersApiService.getNotAssignedOwners();
    if (response.statusCode == 200) {
      setState(() {
        availableOwners = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _loadAvailableRoomers() async {
    final response = await RoomerApiService.getNotAssignedRoomers();
    if (response.statusCode == 200) {
      setState(() {
        availableRoomers = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _assignOwner(int ownerId) async {
    final response =
        await OwnersApiService.assignUserToOwner(ownerId, widget.userId);
    if (response.statusCode == 200) {
      _loadCurrentOwners();
      _loadAvailableOwners();
    } else {}
  }

  Future<void> _removeOwner(int ownerId) async {
    final response =
        await OwnersApiService.removeUserOfOwner(ownerId, widget.userId);
    if (response.statusCode == 200) {
      _loadCurrentOwners();
      _loadAvailableOwners();
    } else {}
  }

  Future<void> _assignRoomer(int roomerId) async {
    final response =
        await RoomerApiService.assignUserToRoomer(roomerId, widget.userId);
    if (response.statusCode == 200) {
      _loadCurrentRoomers();
      _loadAvailableRoomers();
    } else {}
  }

  Future<void> _removeRoomer(int roomerId) async {
    final response =
        await RoomerApiService.removeUserOfRoomer(roomerId, widget.userId);
    if (response.statusCode == 200) {
      _loadCurrentRoomers();
      _loadAvailableRoomers();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar a Propietarios o Inquilinos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Propietarios asignados:', style: AppTheme.textBold),
            ...currentOwners.map((owner) => ListTile(
                  title: Text(owner['name'], style: AppTheme.textSmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: AppTheme.dangerColor),
                    onPressed: () => _removeOwner(owner['ID']),
                  ),
                )),
            const Divider(),
            const Text('Inquilinos asignados:', style: AppTheme.textBold),
            ...currentRoomers.map((roomer) => ListTile(
                  title: Text(roomer['name'], style: AppTheme.textSmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: AppTheme.dangerColor),
                    onPressed: () => _removeRoomer(roomer['ID']),
                  ),
                )),
            const Divider(),
            const Text('Propietarios sin usuario asignado:', style: AppTheme.textBold),
            ...availableOwners.map((owner) => ListTile(
                  title: Text(owner['name'], style: AppTheme.textSmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.successColor),
                    onPressed: () => _assignOwner(owner['ID']),
                  ),
                )),
            const Divider(),
            const Text('Inquilinos sin usuario asignado:', style: AppTheme.textBold),
            ...availableRoomers.map((roomer) => ListTile(
                  title: Text(roomer['name'], style: AppTheme.textSmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.successColor),
                    onPressed: () => _assignRoomer(roomer['ID']),
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar', style: AppTheme.textSmallBold),
        ),
      ],
    );
  }
}
