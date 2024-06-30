import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/components/expense_dialog.dart';
import 'package:frontend_seminario/services/api/consortium_expenses_api_service.dart';
import 'package:frontend_seminario/services/api/unit_expenses_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:intl/intl.dart';

class ManageExpensesPage extends StatefulWidget {
  const ManageExpensesPage({super.key});

  @override
  ManageExpensesPageState createState() => ManageExpensesPageState();
}

class ManageExpensesPageState extends State<ManageExpensesPage> {
  List<dynamic> consortiumExpenses = [];
  List<dynamic> unitExpenses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConsortiumExpenses();
    _loadUnitExpenses();
  }

  Future<void> _loadConsortiumExpenses() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await ConsortiumExpensesApiService.getAllConsortiumExpenses();
    if (response.statusCode == 200) {
      setState(() {
        consortiumExpenses = jsonDecode(response.body)
            .where((expense) => !expense['distributed'])
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _loadUnitExpenses() async {
    setState(() {
      isLoading = true;
    });
    final response = await UnitExpensesApiService.getAllUnitsExpenses();
    if (response.statusCode == 200) {
      List<dynamic> allUnitExpenses = jsonDecode(response.body);
      setState(() {
        unitExpenses = allUnitExpenses
            .where((expense) => !expense['liquidated'] && !expense['paid'])
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  void _createOrUpdateConsortiumExpense([int? expenseId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          ExpenseDialog(expenseId: expenseId, isConsortiumExpense: true),
    );

    if (result != null) {
      final response = expenseId != null
          ? await ConsortiumExpensesApiService.editConsortiumExpense(
              expenseId, result)
          : await ConsortiumExpensesApiService.createConsortiumExpense(result);

      if (response.statusCode == 200) {
        _loadConsortiumExpenses(); // Refresh list after update
      } else {
        // Handle errors
      }
    }
  }

  void _createOrUpdateUnitExpense([int? expenseId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          ExpenseDialog(expenseId: expenseId, isConsortiumExpense: false),
    );

    if (result != null) {
      final response = expenseId != null
          ? await UnitExpensesApiService.editUnitExpense(expenseId, result)
          : await UnitExpensesApiService.createUnitExpense(result);

      if (response.statusCode == 200) {
        _loadUnitExpenses(); // Refresh list after update
      } else {
        // Handle errors
      }
    }
  }

  void _deleteConsortiumExpense(int expenseId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea eliminar esta expensa?'),
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
          await ConsortiumExpensesApiService.deleteConsortiumExpense(expenseId);
      if (response.statusCode == 200) {
        _loadConsortiumExpenses(); // Refresh list after deletion
      } else {
        // Handle errors
      }
    }
  }

  void _deleteUnitExpense(int expenseId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('Esta seguro que desea borrar esta expensa?'),
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
          await UnitExpensesApiService.deleteUnitExpense(expenseId);
      if (response.statusCode == 200) {
        _loadUnitExpenses(); // Refresh list after deletion
      } else {
        // Handle errors
      }
    }
  }

  void _distributeConsortiumExpense(int expenseId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Distribucion'),
        content: const Text('Esta seguro que desea distribuir la expensa?'),
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
          await ConsortiumExpensesApiService.distributeConsortiumExpense(
              expenseId);
      if (mounted) {
        if (response.statusCode == 200) {
          _loadConsortiumExpenses(); // Refresh list after distribution
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expensa distribuida exitosamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fallo al distribuir')),
          );
          // Handle errors
        }
      }
    }
  }

  String _formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestionar Expensas',
      isAdmin: true, // Set according to the user's role
      storageService: StorageService(), // Provide the storage service instance
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _createOrUpdateConsortiumExpense(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Agregar Expensa de Consorcio'),
            ),
            const SizedBox(height: 16),
            const Text('Expensas de Consorcio', style: AppTheme.textBold),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: consortiumExpenses.length,
                  itemBuilder: (context, index) {
                    var expense = consortiumExpenses[index];
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
                                'Numero de Factura: ${expense['bill_number']}'),
                            Text('Concepto: ${expense['concept']['name']}'),
                            Text('Consorcio: ${expense['consortium']['name']}'),
                            Text(
                                'Fecha de Expensa: ${_formatDate(expense['expense_period'])}'),
                            Text(
                                'Periodo de Liquidacion: ${_formatDate(expense['liquidate_period'])}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppTheme.infoColor),
                              onPressed: () => _createOrUpdateConsortiumExpense(
                                  expense['ID']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppTheme.dangerColor),
                              onPressed: () =>
                                  _deleteConsortiumExpense(expense['ID']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send,
                                  color: AppTheme.successColor),
                              onPressed: () =>
                                  _distributeConsortiumExpense(expense['ID']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createOrUpdateUnitExpense(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Agregar Expensa de Unidad'),
            ),
            const SizedBox(height: 16),
            const Text('Expensas de Unidades', style: AppTheme.textBold),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: unitExpenses.length,
                  itemBuilder: (context, index) {
                    var expense = unitExpenses[index];
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
                                'Numero de Factura: ${expense['bill_number']}'),
                            Text('Concepto: ${expense['concept']['name']}'),
                            Text('Unidad: ${expense['unit']['name']}'),
                            Text(
                                'Fecha de Expensa: ${_formatDate(expense['expense_period'])}'),
                            Text(
                                'Periodo de Liquidacion: ${_formatDate(expense['liquidate_period'])}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppTheme.infoColor),
                              onPressed: () =>
                                  _createOrUpdateUnitExpense(expense['ID']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppTheme.dangerColor),
                              onPressed: () =>
                                  _deleteUnitExpense(expense['ID']),
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
      ),
    );
  }
}
