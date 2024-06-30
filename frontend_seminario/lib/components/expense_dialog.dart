import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/concept_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_expenses_api_service.dart';
import 'package:frontend_seminario/services/api/unit_expenses_api_service.dart';
import 'package:intl/intl.dart';
import 'package:frontend_seminario/theme/theme.dart';

class ExpenseDialog extends StatefulWidget {
  final int? expenseId;
  final bool isConsortiumExpense;

  const ExpenseDialog(
      {super.key, this.expenseId, required this.isConsortiumExpense});

  @override
  ExpenseDialogState createState() => ExpenseDialogState();
}

class ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _expenseDate;
  DateTime? _liquidateDate;
  bool _isLoading = false;
  List<dynamic> _concepts = [];
  List<dynamic> _consortiums = [];
  List<dynamic> _units = [];
  int? _selectedConceptId;
  int? _selectedConsortiumId;
  int? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExpenseData();
    }
    _loadConcepts();
    _loadConsortiums();
  }

  Future<void> _loadConcepts() async {
    final response = await ConceptApiService.getAllConcepts();
    if (response.statusCode == 200) {
      setState(() {
        _concepts = jsonDecode(response.body).where((concept) {
          if (widget.isConsortiumExpense) {
            return concept['origin'] == 'Debe' &&
                concept['coefficient']['distributable'] == true;
          } else {
            return concept['origin'] == 'Debe';
          }
        }).toList();
      });
    } else {}
  }

  Future<void> _loadConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      setState(() {
        _consortiums = jsonDecode(response.body);
      });
    } else {}
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

  Future<void> _loadExpenseData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = widget.isConsortiumExpense
          ? await ConsortiumExpensesApiService.getConsortiumExpenseById(
              widget.expenseId!)
          : await UnitExpensesApiService.getUnitsExpensesByUnit(
              widget.expenseId!);
      if (response.statusCode == 200) {
        final expense = jsonDecode(response.body);
        setState(() {
          _descriptionController.text = expense['description'] ?? '';
          _amountController.text = expense['amount']?.toString() ?? '';
          _expenseDate = DateTime.tryParse(expense['expense_period']);
          _liquidateDate = DateTime.tryParse(expense['liquidate_period']);
          _selectedConceptId = expense['concept_id'];
          if (widget.isConsortiumExpense) {
            _selectedConsortiumId = expense['consortium_id'];
          } else {
            _selectedConsortiumId = expense['unit']['consortium_id'];
            _selectedUnitId = expense['unit_id'];
            _loadUnitsByConsortium(_selectedConsortiumId!);
          }
        });
      } else {}
    } catch (e) {
      print('Exception loading expense data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> expenseData = {
        'description': _descriptionController.text,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'left_to_pay': double.tryParse(_amountController.text) ?? 0.0,
        'expense_period':
            '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(_expenseDate!)}Z',
        'liquidate_period':
            '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(_liquidateDate!)}Z',
        'concept_id': _selectedConceptId,
        if (widget.isConsortiumExpense) 'consortium_id': _selectedConsortiumId,
        if (!widget.isConsortiumExpense) 'unit_id': _selectedUnitId,
      };
      Navigator.of(context).pop(expenseData);
    }
  }

  Future<void> _selectExpenseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expenseDate) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  Future<void> _selectLiquidateDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _liquidateDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _liquidateDate) {
      setState(() {
        _liquidateDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expenseId == null ? 'Create Expense' : 'Edit Expense'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: TextEditingController(
                                text: _expenseDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_expenseDate!)
                                    : ''),
                            decoration: const InputDecoration(
                              labelText: 'Expense Date',
                              labelStyle: AppTheme.textSmall,
                              filled: true,
                              fillColor: AppTheme.lightBackground,
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                            onTap: () async {
                              await _selectExpenseDate();
                            },
                            readOnly: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectExpenseDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: TextEditingController(
                                text: _liquidateDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_liquidateDate!)
                                    : ''),
                            decoration: const InputDecoration(
                              labelText: 'Liquidate Date',
                              labelStyle: AppTheme.textSmall,
                              filled: true,
                              fillColor: AppTheme.lightBackground,
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                            onTap: () async {
                              await _selectLiquidateDate();
                            },
                            readOnly: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectLiquidateDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Select Concept',
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
                          child:
                              Text(concept['name'], style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedConceptId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a concept';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Select Consortium',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: _selectedConsortiumId,
                      items:
                          _consortiums.map<DropdownMenuItem<int>>((consortium) {
                        return DropdownMenuItem<int>(
                          value: consortium['ID'],
                          child: Text(consortium['name'],
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedConsortiumId = value;
                          _loadUnitsByConsortium(value!);
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a consortium';
                        }
                        return null;
                      },
                    ),
                    if (!widget.isConsortiumExpense) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Select Unit',
                          labelStyle: AppTheme.textSmall,
                          filled: true,
                          fillColor: AppTheme.lightBackground,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        value: _selectedUnitId,
                        items: _units.map<DropdownMenuItem<int>>((unit) {
                          return DropdownMenuItem<int>(
                            value: unit['ID'],
                            child:
                                Text(unit['name'], style: AppTheme.textSmall),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnitId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a unit';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: AppTheme.textSmallBold),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Save', style: AppTheme.textSmallBold),
        ),
      ],
    );
  }
}
