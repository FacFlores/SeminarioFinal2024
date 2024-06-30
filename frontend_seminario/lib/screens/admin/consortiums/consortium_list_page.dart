import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/components/consortium_dialog.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:go_router/go_router.dart';

class ConsortiumListPage extends StatefulWidget {
  const ConsortiumListPage({super.key});

  @override
  ConsortiumListPageState createState() => ConsortiumListPageState();
}

class ConsortiumListPageState extends State<ConsortiumListPage> {
  List<dynamic> consortiums = [];

  @override
  void initState() {
    super.initState();
    _loadConsortiums();
  }

  Future<void> _loadConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      setState(() {
        consortiums = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  void _createOrUpdateConsortium([int? consortiumId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConsortiumDialog(consortiumId: consortiumId),
    );

    if (result != null) {
      final response = consortiumId != null
          ? await ConsortiumApiService.editConsortium(consortiumId, result)
          : await ConsortiumApiService.createConsortium(result);

      if (response.statusCode == 200) {
        _loadConsortiums(); // Refresh list after update
      } else {
        // Handle errors
      }
    }
  }

  void _deleteConsortium(int consortiumId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea eliminar el consorcio?'),
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
      final response =
          await ConsortiumApiService.deleteConsortium(consortiumId);
      if (response.statusCode == 200) {
        _loadConsortiums(); // Refresh list after deletion
      } else {
        // Handle errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestion de Consorcios',
      body: _buildConsortiumList(),
      isAdmin: true,
      storageService: StorageService(),
    );
  }

  Widget _buildConsortiumList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _createOrUpdateConsortium(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Agregar Consorcio'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: consortiums.length,
              itemBuilder: (context, index) {
                var consortium = consortiums[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(consortium['name'], style: AppTheme.textMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Direccion: ${consortium['address']}',
                            style: AppTheme.textSmall),
                        Text('CUIT: ${consortium['cuit']}',
                            style: AppTheme.textSmall),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () =>
                              _createOrUpdateConsortium(consortium['ID']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () => _deleteConsortium(consortium['ID']),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.go(
                        '/admin/consortiums/${consortium['ID']}/units',
                        extra: consortium['name'],
                      );
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
