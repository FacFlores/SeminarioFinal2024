import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_seminario/services/api/unit_expenses_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';

class PendingExpensesPage extends StatefulWidget {
  const PendingExpensesPage({super.key});

  @override
  PendingExpensesPageState createState() => PendingExpensesPageState();
}

class PendingExpensesPageState extends State<PendingExpensesPage> {
  bool _isLoading = true;
  Map<String, List<dynamic>> _unitExpenses = {};

  @override
  void initState() {
    super.initState();
    _fetchPendingExpenses();
  }

  Future<void> _fetchPendingExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await StorageService().getUserData();
      final unitsResponse = await UserApiService.getUnitsByUser(user!['ID']);
      final expensesResponse =
          await UnitExpensesApiService.getAllUnitsExpenses();

      if (unitsResponse.statusCode == 200 &&
          expensesResponse.statusCode == 200) {
        final units = jsonDecode(unitsResponse.body);
        final expenses = jsonDecode(expensesResponse.body);

        setState(() {
          _unitExpenses = {};

          for (var unit in units) {
            final unitId = unit['ID'];
            final unitName = unit['name'];
            _unitExpenses[unitName] = expenses.where((expense) {
              return expense['unit_id'] == unitId &&
                  expense['liquidated'] &&
                  !expense['paid'];
            }).toList();
          }

          _isLoading = false;
        });
      } else {
        print(
            'Error fetching pending expenses: ${unitsResponse.body}, ${expensesResponse.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  String _formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Expensas a Pagar',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: _unitExpenses.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay expensas pendientes de pago',
                              style: AppTheme.textMedium,
                            ),
                          )
                        : ListView(
                            children: _unitExpenses.keys.map((unitName) {
                              final expenses = _unitExpenses[unitName]!;
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    title: Text(unitName,
                                        style: AppTheme.titleMedium.copyWith(
                                            color: AppTheme.primaryColor)),
                                    iconColor: AppTheme.primaryColor,
                                    children: expenses.isNotEmpty
                                        ? expenses.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            var expense = entry.value;
                                            return Container(
                                              color: index % 2 == 0
                                                  ? AppTheme.lightBackground
                                                      .withOpacity(0.5)
                                                  : Colors.white,
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                        expense['description'],
                                                        style: AppTheme
                                                            .textMedium),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'Cantidad: ${expense['amount']}',
                                                            style: AppTheme
                                                                .textSmall),
                                                        Text(
                                                            'Restante de Pago: ${expense['left_to_pay']}',
                                                            style: AppTheme
                                                                .textSmall),
                                                        Text(
                                                            'Numero de Factura: ${expense['bill_number']}',
                                                            style: AppTheme
                                                                .textSmall),
                                                        Text(
                                                            'Fecha de Expensa: ${_formatDate(expense['expense_period'])}',
                                                            style: AppTheme
                                                                .textSmall),
                                                        Text(
                                                            'Periodo de Liquidacion: ${_formatDate(expense['liquidate_period'])}',
                                                            style: AppTheme
                                                                .textSmall),
                                                      ],
                                                    ),
                                                    isThreeLine: true,
                                                  ),
                                                  if (index <
                                                      expenses.length - 1)
                                                    const Divider(),
                                                ],
                                              ),
                                            );
                                          }).toList()
                                        : [
                                            const ListTile(
                                              title: Text(
                                                'No existen expensas pendientes para esta unidad',
                                                style: AppTheme.textSmall,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
      isAdmin: false,
      storageService: StorageService(),
    );
  }
}
