import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/components/concept_dialog.dart';
import 'package:frontend_seminario/services/api/concept_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';

class ManageConceptsPage extends StatefulWidget {
  const ManageConceptsPage({super.key});

  @override
  ManageConceptsPageState createState() => ManageConceptsPageState();
}

class ManageConceptsPageState extends State<ManageConceptsPage> {
  List<dynamic> concepts = [];

  @override
  void initState() {
    super.initState();
    _loadConcepts();
  }

  Future<void> _loadConcepts() async {
    final response = await ConceptApiService.getAllConcepts();
    if (response.statusCode == 200) {
      setState(() {
        concepts = jsonDecode(response.body);
      });
    } else {
      // Handle error
    }
  }

  void _createOrUpdateConcept([int? conceptId]) async {
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConceptDialog(conceptId: conceptId),
    );

    if (result != null) {
      final response = conceptId != null
          ? await ConceptApiService.editConcept(conceptId, result)
          : await ConceptApiService.createConcept(result);

      if (response.statusCode == 200) {
        _loadConcepts(); // Refresh list after update
      } else {
        // Handle errors
      }
    }
  }

  void _deleteConcept(int conceptId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this concept?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: AppTheme.textSmall),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: AppTheme.textSmallBold),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await ConceptApiService.deleteConcept(conceptId);
      if (response.statusCode == 200) {
        _loadConcepts(); // Refresh list after deletion
      } else {
        // Handle errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Manage Concepts',
      body: _buildContent(),
      isAdmin: true,
      storageService: StorageService(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _createOrUpdateConcept(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Add Concept'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: concepts.length,
              itemBuilder: (context, index) {
                var concept = concepts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(concept['name'], style: AppTheme.textMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${concept['description']}',
                            style: AppTheme.textSmall),
                        Text('Type: ${concept['type']}',
                            style: AppTheme.textSmall),
                        Text('Origin: ${concept['origin']}',
                            style: AppTheme.textSmall),
                        Text('Coefficient: ${concept['coefficient']['name']}',
                            style: AppTheme.textSmall),
                        Text('Priority: ${concept['priority']}',
                            style: AppTheme.textSmall),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppTheme.infoColor),
                          onPressed: () =>
                              _createOrUpdateConcept(concept['ID']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppTheme.dangerColor),
                          onPressed: () => _deleteConcept(concept['ID']),
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
    );
  }
}
