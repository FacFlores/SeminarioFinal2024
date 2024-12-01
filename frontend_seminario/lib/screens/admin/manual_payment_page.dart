import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/api/concept_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/unit_expenses_api_service.dart';
import 'package:frontend_seminario/services/api/payments_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:intl/intl.dart';

class ManualPaymentPage extends StatefulWidget {
  const ManualPaymentPage({super.key});

  @override
  ManualPaymentPageState createState() => ManualPaymentPageState();
}

class ManualPaymentPageState extends State<ManualPaymentPage> {
  List<dynamic> _consortiums = [];
  List<dynamic> _units = [];
  List<dynamic> _expenses = [];
  List<dynamic> _concepts = [];
  int? _selectedConsortiumId;
  int? _selectedUnitId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConsortiums();
    _loadConcepts();
  }

  Future<void> _loadConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      setState(() {
        _consortiums = jsonDecode(response.body);
      });
    } else {
      print('Error loading consortiums: ${response.body}');
    }
  }

  Future<void> _loadConcepts() async {
    final response = await ConceptApiService.getAllConcepts();
    if (response.statusCode == 200) {
      setState(() {
        _concepts = jsonDecode(response.body).where((concept) {
          return concept['origin'] == 'Haber';
        }).toList();
      });
    } else {
      print('Error loading concepts: ${response.body}');
    }
  }

  Future<void> _loadUnitsByConsortium(int consortiumId) async {
    final response = await UnitApiService.getUnitsByConsortium(consortiumId);
    if (response.statusCode == 200) {
      setState(() {
        _units = jsonDecode(response.body);
      });
    } else {
      print('Error loading units by consortium: ${response.body}');
    }
  }

  Future<void> _loadExpenses() async {
    if (_selectedConsortiumId == null || _selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor seleccione un consorcio y una unidad')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response =
        await UnitExpensesApiService.getUnitsExpensesByUnit(_selectedUnitId!);
    if (response.statusCode == 200) {
      setState(() {
        _expenses = jsonDecode(response.body).where((expense) {
          return !expense['paid'];
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error loading unit expenses: ${response.body}');
    }
  }

  Future<void> _payExpense(int expenseId, double leftToPay) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    int? selectedConceptId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirmar Pago', style: AppTheme.textMedium),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: AppTheme.textSmall,
                      filled: true,
                      fillColor: AppTheme.lightBackground,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripcion',
                      labelStyle: AppTheme.textSmall,
                      filled: true,
                      fillColor: AppTheme.lightBackground,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Seleccione concepto de pago',
                      labelStyle: AppTheme.textSmall,
                      filled: true,
                      fillColor: AppTheme.lightBackground,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                    value: selectedConceptId,
                    items: _concepts.map<DropdownMenuItem<int>>((concept) {
                      return DropdownMenuItem<int>(
                        value: concept['ID'],
                        child: Text(concept['name'], style: AppTheme.textSmall),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedConceptId = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar', style: AppTheme.textSmall),
                ),
                TextButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    if (amount > leftToPay) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('La cantidad excede el restante de pago')),
                      );
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Confirmar', style: AppTheme.textSmallBold),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final description = descriptionController.text;
      if (mounted) {
        if (selectedConceptId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleccione un concepto de pago')),
          );
          return;
        }
      }
      final postData = {
        'amount': amount,
        'description': description,
        'concept_id': selectedConceptId
      };

      final response =
          await PaymentsApiService.payUnitExpense(expenseId, postData);
      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expensa pagada exitosamente')),
          );
          _loadExpenses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fallo al pagar expensa')),
          );
          print('Error paying expense: ${response.body}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Pago manual de expensa',
      isAdmin: true,
      storageService: StorageService(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('', style: AppTheme.textBold),
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
                  _expenses = [];
                });
              },
            ),
            const SizedBox(height: 16),
            if (_units.isNotEmpty)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Seleccione una Propiedad',
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? const Center(child: Text('Sin expensas por pagar'))
                    : Expanded(
                        child: ListView.builder(
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
                                    Text('Cantidad: ${expense['amount']}',
                                        style: AppTheme.textSmall),
                                    Text(
                                        'Numero de Factura: ${expense['bill_number']}',
                                        style: AppTheme.textSmall),
                                    Text(
                                        'Concepto: ${expense['concept']['name']}',
                                        style: AppTheme.textSmall),
                                    Text(
                                        'Fecha de Expensa: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['expense_period']))}',
                                        style: AppTheme.textSmall),
                                    Text(
                                        'Periodo de Liquidacion : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['liquidate_period']))}',
                                        style: AppTheme.textSmall),
                                    Text(
                                        'Restante de Pago: ${expense['left_to_pay']}',
                                        style: AppTheme.textSmall),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _payExpense(
                                      expense['ID'], expense['left_to_pay']),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppTheme.primaryColor,
                                  ),
                                  child: const Text('Pagar',
                                      style: AppTheme.textSmallBold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
