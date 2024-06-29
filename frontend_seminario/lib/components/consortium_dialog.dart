import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class ConsortiumDialog extends StatefulWidget {
  final int? consortiumId;

  const ConsortiumDialog({super.key, this.consortiumId});

  @override
  ConsortiumDialogState createState() => ConsortiumDialogState();
}

class ConsortiumDialogState extends State<ConsortiumDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cuitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.consortiumId != null) {
      _loadConsortiumData();
    }
  }

  Future<void> _loadConsortiumData() async {
    final response =
        await ConsortiumApiService.getConsortiumById(widget.consortiumId!);
    if (response.statusCode == 200) {
      final consortium = jsonDecode(response.body);
      setState(() {
        _nameController.text = consortium['name'];
        _addressController.text = consortium['address'];
        _cuitController.text = consortium['cuit'];
      });
    } else {
      // Handle errors or show error message
    }
  }

  void _saveConsortium() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> consortiumData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'cuit': _cuitController.text,
      };
      if (widget.consortiumId != null) {
        consortiumData['id'] = widget.consortiumId;
      }
      Navigator.of(context).pop(consortiumData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.consortiumId == null
          ? 'Create Consortium'
          : 'Edit Consortium'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', labelStyle: AppTheme.textSmall),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: 'Address', labelStyle: AppTheme.textSmall),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cuitController,
                decoration: const InputDecoration(
                    labelText: 'CUIT', labelStyle: AppTheme.textSmall),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a CUIT';
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
          onPressed: _saveConsortium,
          child: const Text('Save', style: AppTheme.textSmallBold),
        ),
      ],
    );
  }
}
