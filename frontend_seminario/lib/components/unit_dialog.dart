import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class UnitDialog extends StatefulWidget {
  final int? unitId;
  final int consortiumId;

  const UnitDialog({super.key, this.unitId, required this.consortiumId});

  @override
  UnitDialogState createState() => UnitDialogState();
}

class UnitDialogState extends State<UnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.unitId != null) {
      _loadUnitData();
    }
  }

  Future<void> _loadUnitData() async {
    final response = await UnitApiService.getUnitById(widget.unitId!);
    if (response.statusCode == 200) {
      final unit = jsonDecode(response.body);
      _nameController.text = unit['name'];
    } else {
      // Handle errors or show error message
    }
  }

  void _saveUnit() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> unitData = {
        'name': _nameController.text,
        'consortium_id': widget.consortiumId, // Ensure the field name matches the backend
      };
      Navigator.of(context).pop(unitData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unitId == null ? 'Create Unit' : 'Edit Unit'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', labelStyle: AppTheme.textSmall),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: AppTheme.textSmall),
        ),
        TextButton(
          onPressed: _saveUnit,
          child: const Text('Save', style: AppTheme.textSmallBold),
        ),
      ],
    );
  }
}

