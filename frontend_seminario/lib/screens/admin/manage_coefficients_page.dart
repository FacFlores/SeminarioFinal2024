import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/components/coefficient_dialog.dart';
import 'package:frontend_seminario/services/api/coefficient_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class ManageCoefficientsPage extends StatefulWidget {
  const ManageCoefficientsPage({super.key});

  @override
  ManageCoefficientsPageState createState() => ManageCoefficientsPageState();
}

class ManageCoefficientsPageState extends State<ManageCoefficientsPage> {
  List<dynamic> coefficients = [];

  @override
  void initState() {
    super.initState();
    _loadCoefficients();
  }

  Future<void> _loadCoefficients() async {
    final response = await CoefficientApiService.getAllCoefficients();
    if (response.statusCode == 200) {
      setState(() {
        coefficients = jsonDecode(response.body);
      });
    } else {}
  }

  void _createOrUpdateCoefficient([int? coefficientId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CoefficientDialog(coefficientId: coefficientId),
    );

    if (result != null) {
      final response = coefficientId != null
          ? await CoefficientApiService.editCoefficient(coefficientId, result)
          : await CoefficientApiService.createCoefficient(result);

      if (response.statusCode == 200) {
        _loadCoefficients();
      } else {}
    }
  }

  void _deleteCoefficient(int coefficientId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea eliminar el Coeficiente?'),
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
          await CoefficientApiService.deleteCoefficient(coefficientId);
      if (response.statusCode == 200) {
        _loadCoefficients();
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestionar Coeficientes',
      body: _buildContent(),
      isAdmin: true,
      storageService: StorageService(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _createOrUpdateCoefficient(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Agregar Coeficiente'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: coefficients.length,
              itemBuilder: (context, index) {
                var coefficient = coefficients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title:
                        Text(coefficient['name'], style: AppTheme.textMedium),
                    subtitle: Text(
                        'Distribuible: ${coefficient['distributable'] ? 'Si' : 'No'}',
                        style: AppTheme.textSmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () =>
                              _createOrUpdateCoefficient(coefficient['ID']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () =>
                              _deleteCoefficient(coefficient['ID']),
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
