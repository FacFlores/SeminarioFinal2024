import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/components/unit_dialog.dart';
import 'package:frontend_seminario/components/owner_roomer_dialog.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:go_router/go_router.dart';

class ConsortiumUnitsPage extends StatefulWidget {
  final int consortiumId;

  const ConsortiumUnitsPage({
    super.key,
    required this.consortiumId,
  });

  @override
  ConsortiumUnitsPageState createState() => ConsortiumUnitsPageState();
}

class ConsortiumUnitsPageState extends State<ConsortiumUnitsPage> {
  List<dynamic> units = [];
  String consortiumName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadConsortiumDetails();
    _loadUnits();
  }

  Future<void> _loadConsortiumDetails() async {
    final response = await ConsortiumApiService.getConsortiumById(widget.consortiumId);
    if (response.statusCode == 200) {
      setState(() {
        final consortium = jsonDecode(response.body);
        consortiumName = consortium['name'];
      });
    } else {
      // Handle error
    }
  }

  Future<void> _loadUnits() async {
    final response = await UnitApiService.getUnitsByConsortium(widget.consortiumId);
    if (response.statusCode == 200) {
      setState(() {
        units = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  void _createOrUpdateUnit([int? unitId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UnitDialog(unitId: unitId, consortiumId: widget.consortiumId),
    );

    if (result != null) {
      final response = unitId != null
          ? await UnitApiService.editUnit(unitId, result)
          : await UnitApiService.createUnit(result);

      if (response.statusCode == 200) {
        _loadUnits(); // Refresh list after update
      } else {
        // Handle errors
        _showErrorDialog('Failed to save unit. Please try again.');
      }
    }
  }

  void _deleteUnit(int unitId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this unit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: AppTheme.textSmall),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: AppTheme.textSmallBold),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await UnitApiService.deleteUnit(unitId);
      if (response.statusCode == 200) {
        _loadUnits(); // Refresh list after deletion
      } else {
        // Handle errors
        _showErrorDialog('Failed to delete unit. Please try again.');
      }
    }
  }

  void _manageOwnersRoomers(int unitId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => OwnerRoomerDialog(unitId: unitId),
    );
    _loadUnits(); // Refresh list after managing owners/roomers
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: AppTheme.textSmallBold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Units of $consortiumName',
      body: _buildUnitList(),
      isAdmin: true,
      storageService: StorageService(),
    );
  }

  Widget _buildUnitList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/admin/consortiums'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Back to Consortiums'),
              ),
              ElevatedButton(
                onPressed: () => _createOrUpdateUnit(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.accentColor,
                ),
                child: const Text('Add Unit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                var unit = units[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(unit['name'], style: AppTheme.textMedium),
                    subtitle: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.person,
                              color: AppTheme.infoColor),
                          onPressed: () => _manageOwnersRoomers(unit['ID']),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () => _createOrUpdateUnit(unit['ID']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () => _deleteUnit(unit['ID']),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Optionally, navigate to unit details or other actions
                    },
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
