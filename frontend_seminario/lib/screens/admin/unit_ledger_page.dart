import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/ledger_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:intl/intl.dart';

class UnitLedgerPage extends StatefulWidget {
  const UnitLedgerPage({super.key});

  @override
  UnitLedgerPageState createState() => UnitLedgerPageState();
}

class UnitLedgerPageState extends State<UnitLedgerPage> {
  List<dynamic> _consortiums = [];
  List<dynamic> _units = [];
  List<dynamic> _transactions = [];
  double? _unitBalance;
  int? _selectedConsortiumId;
  int? _selectedUnitId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConsortiums();
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

  Future<void> _loadUnitBalanceAndTransactions() async {
    if (_selectedConsortiumId == null || _selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor seleccione un Consorcio y una Unidad')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final balanceResponse =
        await LedgerApiService.getUnitBalance(_selectedUnitId!);
    final transactionsResponse =
        await LedgerApiService.getUnitTransactions(_selectedUnitId!);

    if (balanceResponse.statusCode == 200 &&
        transactionsResponse.statusCode == 200) {
      setState(() {
        _unitBalance = jsonDecode(balanceResponse.body)['balance'];
        _transactions = jsonDecode(transactionsResponse.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error loading unit balance or transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Balance de Unidades',
      isAdmin: true,
      storageService: StorageService(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(' ', style: AppTheme.textBold),
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
                  _unitBalance = null;
                  _transactions = [];
                  _loadUnitsByConsortium(value!);
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
                    _loadUnitBalanceAndTransactions();
                  });
                },
              ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_unitBalance != null)
              Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title:
                      const Text('Balance Actual', style: AppTheme.textMedium),
                  subtitle: Text(
                    '\$${_unitBalance!.toStringAsFixed(2)}',
                    style: AppTheme.textBold.copyWith(
                      color: _unitBalance! >= 0
                          ? AppTheme.successColor
                          : AppTheme.dangerColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text('Historial de Transacciones', style: AppTheme.textBold),
            if (_transactions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    var transaction = _transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          transaction['description'],
                          style: AppTheme.textMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: \$${transaction['amount']}',
                                style: AppTheme.textSmall),
                            Text(
                                'Fecha de transacción: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction['date']))}',
                                style: AppTheme.textSmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Center(
                  child: Text('No hay transacciones registradas',
                      style: AppTheme.textSmall)),
          ],
        ),
      ),
    );
  }
}
