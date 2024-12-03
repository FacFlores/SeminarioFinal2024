import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/owner_api_service.dart';
import 'package:frontend_seminario/services/api/roomer_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class OwnerRoomerDialog extends StatefulWidget {
  final int unitId;

  const OwnerRoomerDialog({super.key, required this.unitId});

  @override
  OwnerRoomerDialogState createState() => OwnerRoomerDialogState();
}

class OwnerRoomerDialogState extends State<OwnerRoomerDialog> {
  List<dynamic> owners = [];
  List<dynamic> roomers = [];

  @override
  void initState() {
    super.initState();
    _loadOwners();
    _loadRoomers();
  }

  Future<void> _loadOwners() async {
    final response = await UnitApiService.getOwnersByUnit(widget.unitId);
    if (response.statusCode == 200) {
      setState(() {
        owners = jsonDecode(response.body);
      });
    } 
  }

  Future<void> _loadRoomers() async {
    final response = await UnitApiService.getRoomersByUnit(widget.unitId);
    if (response.statusCode == 200) {
      setState(() {
        roomers = jsonDecode(response.body);
      });
    } 
  }

  Future<void> _assignOwner(int ownerId) async {
    final response = await UnitApiService.assignOwner(widget.unitId, ownerId);
    if (response.statusCode == 200) {
      _loadOwners();
    }
  }

  Future<void> _removeOwner(int ownerId) async {
    final response = await UnitApiService.removeOwner(widget.unitId, ownerId);
    if (response.statusCode == 200) {
      _loadOwners();
    } 
  }

  Future<void> _assignRoomer(int roomerId) async {
    final response = await UnitApiService.assignRoomer(widget.unitId, roomerId);
    if (response.statusCode == 200) {
      _loadRoomers(); 
    } 
  }

  Future<void> _removeRoomer(int roomerId) async {
    final response = await UnitApiService.removeRoomer(widget.unitId, roomerId);
    if (response.statusCode == 200) {
      _loadRoomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestionar Propietarios', style: AppTheme.textBold),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Propietarios:', style: AppTheme.textBold),
            ...owners.map((owner) => ListTile(
              title: Text(owner['name'] + ' '+ owner['surname'], style: AppTheme.textSmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: AppTheme.dangerColor),
                    onPressed: () => _removeOwner(owner['ID']),
                  ),
                )),
            ElevatedButton(
              onPressed: () async {
                final ownerId = await showDialog<int>(
                  context: context,
                  builder: (context) => const SelectOwnerDialog(),
                );
                if (ownerId != null) {
                  _assignOwner(ownerId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                textStyle: AppTheme.textSmallBold,
              ),
              child: const Text('Agregar Propietario'),
            ),
            const SizedBox(height: 16),
            const Text('Inquilinos:', style: AppTheme.textBold),
            ...roomers.map((roomer) => ListTile(
              title: Text(roomer['name'] + ' '+ roomer['surname'], style: AppTheme.textSmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: AppTheme.dangerColor),
                    onPressed: () => _removeRoomer(roomer['ID']),
                  ),
                )),
            ElevatedButton(
              onPressed: () async {
                final roomerId = await showDialog<int>(
                  context: context,
                  builder: (context) => const SelectRoomerDialog(),
                );
                if (roomerId != null) {
                  _assignRoomer(roomerId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                textStyle: AppTheme.textSmallBold,
              ),
              child: const Text('Agregar Inquilino'),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

class SelectOwnerDialog extends StatefulWidget {
  const SelectOwnerDialog({super.key});

  @override
  SelectOwnerDialogState createState() => SelectOwnerDialogState();
}

class SelectOwnerDialogState extends State<SelectOwnerDialog> {
  List<dynamic> owners = [];

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    final response = await OwnersApiService.getAllOwners();
    if (response.statusCode == 200) {
      setState(() {
        owners = jsonDecode(response.body);
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccione un Propietario', style: AppTheme.textBold),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: owners.map((owner) {
            return ListTile(
              title: Text(owner['name'] + ' '+ owner['surname'], style: AppTheme.textSmall),
              onTap: () => Navigator.of(context).pop(owner['ID']),
            );
          }).toList(),
        ),
      ),
      backgroundColor: AppTheme.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

class SelectRoomerDialog extends StatefulWidget {
  const SelectRoomerDialog({super.key});

  @override
  SelectRoomerDialogState createState() => SelectRoomerDialogState();
}

class SelectRoomerDialogState extends State<SelectRoomerDialog> {
  List<dynamic> roomers = [];

  @override
  void initState() {
    super.initState();
    _loadRoomers();
  }

  Future<void> _loadRoomers() async {
    final response = await RoomerApiService.getAllRoomers();
    if (response.statusCode == 200) {
      setState(() {
        roomers = jsonDecode(response.body);
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccione un Inquilino', style: AppTheme.textBold),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: roomers.map((roomer) {
            return ListTile(
              title: Text(roomer['name'] + ' ' + roomer['surname'], style: AppTheme.textSmall),
              onTap: () => Navigator.of(context).pop(roomer['ID']),
            );
          }).toList(),
        ),
      ),
      backgroundColor: AppTheme.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
