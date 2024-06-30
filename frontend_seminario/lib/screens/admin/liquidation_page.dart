import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/unit_expenses_api_service.dart';
import 'package:frontend_seminario/services/api/liquidation_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:intl/intl.dart';

class LiquidationPage extends StatefulWidget {
  const LiquidationPage({super.key});

  @override
  LiquidationPageState createState() => LiquidationPageState();
}

class LiquidationPageState extends State<LiquidationPage> {
  List<dynamic> _consortiums = [];
  List<dynamic> _units = [];
  List<dynamic> _expenses = [];
  int? _selectedConsortiumId;
  int? _selectedUnitId;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConsortiums();
  }

  Future<void> _loadConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _consortiums = jsonDecode(response.body);
        });
      }
    } else {
      print('Error loading consortiums: ${response.body}');
    }
  }

  Future<void> _loadUnitsByConsortium(int consortiumId) async {
    final response = await UnitApiService.getUnitsByConsortium(consortiumId);
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _units = jsonDecode(response.body);
        });
      }
    } else {
      print('Error loading units by consortium: ${response.body}');
    }
  }

  Future<void> _loadExpenses() async {
    if (_selectedConsortiumId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor seleccione un consorcio y fecha')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final year = _selectedDate!.year;
    final month = _selectedDate!.month;

    final response = await UnitExpensesApiService.getAllUnitsExpenses();
    if (response.statusCode == 200) {
      final allExpenses = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          _expenses = allExpenses.where((expense) {
            final liquidateDate = DateTime.parse(expense['liquidate_period']);
            final matchesDate =
                liquidateDate.year == year && liquidateDate.month == month;
            if (_selectedUnitId != null) {
              return !expense['liquidated'] &&
                  matchesDate &&
                  expense['unit_id'] == _selectedUnitId;
            } else {
              return !expense['liquidated'] &&
                  matchesDate &&
                  expense['unit']['consortium_id'] == _selectedConsortiumId;
            }
          }).toList();
        });
      }
    } else {
      print('Error loading unit expenses: ${response.body}');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _liquidateExpenses() async {
    if (_selectedConsortiumId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor seleccione un consorcio y fecha')),
      );
      return;
    }

    final period = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final response = _selectedUnitId != null
        ? await LiquidationApiService.liquidateUnitExpensesByPeriod(
            _selectedUnitId!, period)
        : await LiquidationApiService.liquidateConsortiumExpensesByPeriod(
            _selectedConsortiumId!, period);

    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expensas liquidadas correctamente')),
        );
        _loadExpenses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fallo al liquidar expensas')),
        );
        print('Error liquidating expenses: ${response.body}');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
          _loadExpenses();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Liquidar expensas',
      isAdmin: true,
      storageService: StorageService(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccione un consorcio',
                labelStyle: AppTheme.textSmall,
                filled: true,
                fillColor: AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              value: _selectedConsortiumId,
              items: _consortiums.map<DropdownMenuItem<int>>((consortium) {
                return DropdownMenuItem<int>(
                  value: consortium['ID'],
                  child: Text(consortium['name'], style: AppTheme.textSmall),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedConsortiumId = value;
                  _selectedUnitId = null;
                  _loadUnitsByConsortium(value!);
                  _loadExpenses();
                });
              },
            ),
            const SizedBox(height: 16),
            if (_units.isNotEmpty)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Seleccione una Propiedad (Opcional)',
                  labelStyle: AppTheme.textSmall,
                  filled: true,
                  fillColor: AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                value: _selectedUnitId,
                items: _units.map<DropdownMenuItem<int>>((unit) {
                  return DropdownMenuItem<int>(
                    value: unit['ID'],
                    child: Text(unit['name'], style: AppTheme.textSmall),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnitId = value;
                    _loadExpenses();
                  });
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Seleccione una fecha',
                      labelStyle: AppTheme.textSmall,
                      filled: true,
                      fillColor: AppTheme.lightBackground,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                    onTap: () async {
                      await _selectDate();
                    },
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    await _selectDate();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _expenses.isEmpty
                      ? const Center(child: Text('Sin expensas por liquidar'))
                      : ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            var expense = _expenses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(expense['description'],
                                    style: AppTheme.textMedium),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cantidad: ${expense['amount']}'),
                                    Text(
                                        'Numero de Facturacion: ${expense['bill_number']}'),
                                    Text(
                                        'Concepto: ${expense['concept']['name']}'),
                                    Text(
                                        'Fecha de Expensa: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['expense_period']))}'),
                                    Text(
                                        'Periodo de Liquidacion : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['liquidate_period']))}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _liquidateExpenses,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Liquidar Expensas',
                  style: AppTheme.textSmallBold),
            ),
          ],
        ),
      ),
    );
  }
}
