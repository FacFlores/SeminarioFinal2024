import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/api/concept_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/payments_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:intl/intl.dart';

class AutomaticPaymentPage extends StatefulWidget {
  const AutomaticPaymentPage({super.key});

  @override
  AutomaticPaymentPageState createState() => AutomaticPaymentPageState();
}

class AutomaticPaymentPageState extends State<AutomaticPaymentPage> {
  List<dynamic> _consortiums = [];
  List<dynamic> _units = [];
  List<dynamic> _concepts = [];
  int? _selectedConsortiumId;
  int? _selectedUnitId;
  DateTime? _selectedDate;
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedConceptId;
  double? _amount;
  // ignore: unused_field
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
    } else {}
  }

  Future<void> _loadConcepts() async {
    final response = await ConceptApiService.getAllConcepts();
    if (response.statusCode == 200) {
      setState(() {
        _concepts = jsonDecode(response.body).where((concept) {
          return concept['origin'] == 'Haber';
        }).toList();
      });
    } else {}
  }

  Future<void> _loadUnitsByConsortium(int consortiumId) async {
    final response = await UnitApiService.getUnitsByConsortium(consortiumId);
    if (response.statusCode == 200) {
      setState(() {
        _units = jsonDecode(response.body);
      });
    } else {}
  }

  Future<void> _automaticPayment() async {
    if (_selectedConsortiumId == null ||
        _selectedUnitId == null ||
        _selectedYear == null ||
        _selectedMonth == null ||
        _selectedConceptId == null ||
        _amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    final period = DateFormat('yyyy-MM-dd')
        .format(DateTime(_selectedYear!, _selectedMonth!));

    final postData = {
      'unit_id': _selectedUnitId,
      'concept_id': _selectedConceptId,
      'period': period,
      'amount': _amount,
      'year': _selectedYear,
      'month': _selectedMonth,
    };

    setState(() {
      _isLoading = true;
    });

    final response = await PaymentsApiService.automaticPayment(postData);
    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago realizado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fallo al realizar el pago')),
        );
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
      setState(() {
        _selectedDate = picked;
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: ' ',
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
                labelText: 'Seleccione un Consorcio',
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
                      labelText: 'Seleccione la fecha',
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
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccione el concepto del pago',
                labelStyle: AppTheme.textSmall,
                filled: true,
                fillColor: AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              value: _selectedConceptId,
              items: _concepts.map<DropdownMenuItem<int>>((concept) {
                return DropdownMenuItem<int>(
                  value: concept['ID'],
                  child: Text(concept['name'], style: AppTheme.textSmall),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedConceptId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
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
              onChanged: (value) {
                _amount = double.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _automaticPayment,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Pagar de manera automatica',
                  style: AppTheme.textSmallBold),
            ),
          ],
        ),
      ),
    );
  }
}
