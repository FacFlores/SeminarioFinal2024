import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/ledger_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class UnitDetail extends StatefulWidget {
  final int unitId;
  const UnitDetail({super.key, required this.unitId});

  @override
  UnitDetailState createState() => UnitDetailState();
}

class UnitDetailState extends State<UnitDetail> {
  bool _isLoading = true;
  double _balance = 0.0;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchUnitDetails();
  }

  Future<void> _fetchUnitDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final balanceResponse =
          await LedgerApiService.getUnitBalance(widget.unitId);
      final transactionsResponse =
          await LedgerApiService.getUnitTransactions(widget.unitId);

      if (balanceResponse.statusCode == 200 &&
          transactionsResponse.statusCode == 200) {
        setState(() {
          _balance = jsonDecode(balanceResponse.body)['balance'];
          _transactions = jsonDecode(transactionsResponse.body);
          _isLoading = false;
        });
      } else {
        print(
            'Error fetching unit details: ${balanceResponse.body}, ${transactionsResponse.body}');
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

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Detalle de Unidad',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: _balance >= 0
                        ? AppTheme.successColor
                        : AppTheme.dangerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Balance Actual',
                            style: AppTheme.textMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _balance.toStringAsFixed(2),
                            style: AppTheme.titleMedium
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Historial de Transacciones',
                    style: AppTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No se han registrado transacciones',
                              style: AppTheme.textMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              var transaction = _transactions[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: ListTile(
                                  title: Text(transaction['description'],
                                      style: AppTheme.textMedium),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Cantidad: ${transaction['amount']}',
                                          style: AppTheme.textSmall),
                                      Text(
                                          'Fecha de Transaccion: ${transaction['date']}',
                                          style: AppTheme.textSmall),
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
      isAdmin: false,
      storageService: StorageService(),
    );
  }
}
