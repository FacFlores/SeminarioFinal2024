import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';
import 'package:frontend_seminario/services/api/unit_expenses_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class PdfGenerationPage extends StatefulWidget {
  const PdfGenerationPage({super.key});

  @override
  PdfGenerationPageState createState() => PdfGenerationPageState();
}

class PdfGenerationPageState extends State<PdfGenerationPage> {
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
              return expense['unit_id'] == unitId;
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _generatePdf(String unitName, List<dynamic> expenses) async {
    final user = await StorageService().getUserData();

    final pdf = pw.Document();
    double totalToPay =
        expenses.fold(0, (sum, expense) => sum + expense['left_to_pay']);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              color: PdfColors.deepPurple,
              padding: const pw.EdgeInsets.all(20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gastos de Propiedad: $unitName',
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Emitido por:',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('${user?['name']} ${user?['surname']}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                        'Fecha: ${_formatDate(DateTime.now().toIso8601String())}',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: [
                'Descripción',
                'Monto',
                'Pendiente',
                'Número de Factura',
                'Fecha de Gasto',
                'Fecha de Liquidación'
              ],
              data: expenses.map((expense) {
                return [
                  expense['description'],
                  'ARS ${expense['amount'].toStringAsFixed(2)}',
                  'ARS ${expense['left_to_pay'].toStringAsFixed(2)}',
                  expense['bill_number'].toString(),
                  _formatDate(expense['expense_period']),
                  _formatDate(expense['liquidate_period']),
                ];
              }).toList(),
              cellStyle: const pw.TextStyle(fontSize: 12),
              headerStyle: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.deepPurple),
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FixedColumnWidth(50),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(70),
                5: const pw.FixedColumnWidth(90),
              },
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Total a Pagar: ',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('ARS ${totalToPay.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Gracias por su aportacion.',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Soporte: admin@example.com',
                style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$unitName.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Documentacion',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Expensas Pendientes de Pago',
                    style: AppTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _unitExpenses.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay datos disponibles para generar PDFs',
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
                                child: ListTile(
                                  title: Text(unitName,
                                      style: AppTheme.titleMedium.copyWith(
                                          color: AppTheme.primaryColor)),
                                  subtitle: Text(
                                      '${expenses.length} gastos pendientes',
                                      style: AppTheme.textSmall),
                                  trailing: ElevatedButton(
                                    onPressed: () =>
                                        _generatePdf(unitName, expenses),
                                    child: const Text('Generar PDF'),
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
