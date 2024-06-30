import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/api/coefficient_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/unit_coefficients_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class AssignCoefficientsPage extends StatefulWidget {
  const AssignCoefficientsPage({super.key});

  @override
  AssignCoefficientsPageState createState() => AssignCoefficientsPageState();
}

class AssignCoefficientsPageState extends State<AssignCoefficientsPage> {
  List<dynamic> consortiums = [];
  List<dynamic> coefficients = [];
  List<dynamic> units = [];
  int? selectedConsortiumId;
  int? selectedCoefficientId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConsortiums();
    _loadCoefficients();
  }

  Future<void> _loadConsortiums() async {
    try {
      final response = await ConsortiumApiService.getAllConsortiums();
      if (response.statusCode == 200) {
        setState(() {
          consortiums = jsonDecode(response.body);
        });
      } else {
        print('Failed to load consortiums');
      }
    } catch (e) {
      print('Error loading consortiums: $e');
    }
  }

  Future<void> _loadCoefficients() async {
    try {
      final response = await CoefficientApiService.getAllCoefficients();
      if (response.statusCode == 200) {
        setState(() {
          coefficients = jsonDecode(response.body)
              .where((coefficient) => coefficient['distributable'] == true)
              .toList();
        });
      } else {
        print('Failed to load coefficients');
      }
    } catch (e) {
      print('Error loading coefficients: $e');
    }
  }

  Future<void> _loadUnits() async {
    if (selectedConsortiumId != null && selectedCoefficientId != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final unitsResponse =
            await UnitApiService.getUnitsByConsortium(selectedConsortiumId!);
        final coefficientsResponse =
            await UnitCoefficientsApiService.getUnitsWithCoefficients({
          'consortium_id': selectedConsortiumId,
          'coefficient_id': selectedCoefficientId,
        });

        if (unitsResponse.statusCode == 200) {
          List<dynamic> allUnits = jsonDecode(unitsResponse.body);
          List<dynamic> unitCoefficients =
              coefficientsResponse.statusCode == 200
                  ? (jsonDecode(coefficientsResponse.body) ?? [])
                  : [];

          setState(() {
            units = allUnits.map((unit) {
              var unitWithCoefficient = unitCoefficients.firstWhere(
                  (uc) => uc['unit_id'] == unit['ID'],
                  orElse: () => {'percentage': 0.0});
              return {
                'unit_id': unit['ID'],
                'unit_name': unit['name'],
                'percentage': unitWithCoefficient['percentage'] ?? 0.0,
              };
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to load units or coefficients');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error loading units: $e');
      }
    }
  }

  void _updateCoefficientData() {
    double totalPercentage =
        units.fold(0, (sum, unit) => sum + (unit['percentage'] ?? 0));
    if (totalPercentage != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El porcentaje total debe ser igual a 100%')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'coefficient_id': selectedCoefficientId,
      'consortium_id': selectedConsortiumId,
      'units': units.map((unit) {
        return {
          'unit_id': unit['unit_id'],
          'percentage': unit['percentage'],
        };
      }).toList(),
    };

    UnitCoefficientsApiService.createUnitsCoefficients(data).then((response) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Coeficientes de propiedades actualizados correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fallo al actualizar coeficientes')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Asignar Porcentajes a Propiedades',
      isAdmin: true,
      storageService: StorageService(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccione un Consorcio',
                labelStyle: AppTheme.textSmall,
                filled: true,
                fillColor: AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              value: selectedConsortiumId,
              items: consortiums.map<DropdownMenuItem<int>>((consortium) {
                return DropdownMenuItem<int>(
                  value: consortium['ID'],
                  child: Text(consortium['name'], style: AppTheme.textSmall),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedConsortiumId = value;
                  _loadUnits();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccione un Coeficiente',
                labelStyle: AppTheme.textSmall,
                filled: true,
                fillColor: AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              value: selectedCoefficientId,
              items: coefficients.map<DropdownMenuItem<int>>((coefficient) {
                return DropdownMenuItem<int>(
                  value: coefficient['ID'],
                  child: Text(coefficient['name'], style: AppTheme.textSmall),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCoefficientId = value;
                  _loadUnits();
                });
              },
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    var unit = units[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title:
                            Text(unit['unit_name'], style: AppTheme.textMedium),
                        subtitle: Row(
                          children: [
                            const Text('Porcentaje: ',
                                style: AppTheme.textSmall),
                            Expanded(
                              child: TextFormField(
                                initialValue:
                                    unit['percentage']?.toString() ?? '0',
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    unit['percentage'] =
                                        double.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            const Icon(Icons.percent,
                                color: AppTheme.primaryColor)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateCoefficientData,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Actualizar Coeficientes',
                  style: AppTheme.textSmallBold),
            ),
          ],
        ),
      ),
    );
  }
}
