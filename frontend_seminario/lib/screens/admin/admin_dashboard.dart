import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend_seminario/services/api/dashboard_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int? selectedConsortiumID;
  int? selectedUnitID;
  final StorageService storageService = StorageService();
  bool isLoading = true;
  Map<String, dynamic> dashboardData = {};
  String userName = '';
  DateTimeRange? selectedPeriod;
  String currentView = 'overview';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchUserData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await DashboardApiService.getDashboardSummary();
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    final user = await storageService.getUserData();
    if (user != null) {
      setState(() {
        userName = '${user['name']} ${user['surname']}';
      });
    }
  }

Future<void> _selectPeriod() async {
  final pickedPeriod = await showDialog<DateTimeRange>(
    context: context,
    builder: (context) {
      DateTimeRange tempRange = selectedPeriod ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          );

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Seleccionar Período'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Desde:'),
                  trailing: TextButton(
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(tempRange.start),
                      style: AppTheme.textSmall,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempRange.start,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempRange = DateTimeRange(
                            start: picked,
                            end: tempRange.end.isBefore(picked)
                                ? picked.add(const Duration(days: 1))
                                : tempRange.end,
                          );
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Hasta:'),
                  trailing: TextButton(
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(tempRange.end),
                      style: AppTheme.textSmall,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempRange.end,
                        firstDate: tempRange.start,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempRange = DateTimeRange(
                            start: tempRange.start,
                            end: picked,
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Quitar Filtro'),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.pop(context, tempRange);
                },
              ),
            ],
          );
        },
      );
    },
  );

  setState(() {
    selectedPeriod = pickedPeriod;
  });
}

  Map<String, dynamic> _safeCastToMap(dynamic value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return {};
}

List<Map<String, dynamic>> _getPendingExpensesData(Map<String, dynamic> filteredData) {
  final selectedConsortium = (filteredData['consortiumSummary'] as List?)
      ?.firstWhere((c) => c['consortiumID'] == selectedConsortiumID, orElse: () => null);
  
  if (selectedConsortium == null) return [];

  final units = selectedConsortium['units'] as List<dynamic>? ?? [];
  return units
      .where((unit) => unit['pendingExpenses'] != null && unit['pendingExpenses'] > 0)
      .map((unit) => {
            'name': unit['name'],
            'pendingExpenses': unit['pendingExpenses'],
          })
      .toList();
}


Map<String, dynamic> _filterDataByPeriod(DateTimeRange? period) {
  if (period == null) return dashboardData;

  bool isInSelectedRange(String date) {
    final parsedDate = DateTime.parse(date);
    return parsedDate
            .isAfter(period.start.subtract(const Duration(days: 1))) &&
        parsedDate.isBefore(period.end.add(const Duration(days: 1)));
  }

  final filteredGraphData = {
    "expenseByMonth": (_safeCastToMap(dashboardData['graphData'])['expenseByMonth'] ?? [])
        .where((item) => isInSelectedRange(item['month']))
        .toList(),
    "incomeByMonth": (_safeCastToMap(dashboardData['graphData'])['incomeByMonth'] ?? [])
        .where((item) => isInSelectedRange(item['month']))
        .toList(),
  };

  final filteredConsortiumSummary = (_safeCastToMap(dashboardData)['consortiumSummary'] ?? [])
      .map((consortium) {
    final consortiumMap = _safeCastToMap(consortium);
    return {
      ...consortiumMap,
      "expenseByMonth": (consortiumMap['expenseByMonth'] ?? [])
          .where((item) => isInSelectedRange(item['month']))
          .toList(),
      "incomeByMonth": (consortiumMap['incomeByMonth'] ?? [])
          .where((item) => isInSelectedRange(item['month']))
          .toList(),
      "units": (consortiumMap['units'] ?? []).map((unit) {
        final unitMap = _safeCastToMap(unit);
        return {
          ...unitMap,
          "expenseByMonth": (unitMap['expenseByMonth'] ?? [])
              .where((item) => isInSelectedRange(item['month']))
              .toList(),
          "incomeByMonth": (unitMap['incomeByMonth'] ?? [])
              .where((item) => isInSelectedRange(item['month']))
              .toList(),
        };
      }).toList(),
    };
  }).toList();

  return {
    ...dashboardData,
    "graphData": filteredGraphData,
    "consortiumSummary": filteredConsortiumSummary,
  };
}

  @override
  Widget build(BuildContext context) {
    final filteredData = _filterDataByPeriod(selectedPeriod);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.lightBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BaseScaffold(
        title: 'Dashboard Administrativo',
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildViewSwitcher(),
                    const SizedBox(height: 20),
                    if (currentView == 'overview')
                      _buildSummaryCards(filteredData),
                    if (currentView == 'overview') const SizedBox(height: 20),
                    if (currentView == 'overview')
                      _buildGraphSection(filteredData),
                    if (currentView == 'consortium')
                      _buildConsortiumDetails(filteredData),
                    if (currentView == 'unit')
                      _buildUnitDashboard(filteredData),
                    const SizedBox(height: 20),
                    _buildFilters(),
                  ],
                ),
              ),
        isAdmin: true,
        storageService: storageService,
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  '  Filtrar por Período:',
                  style: AppTheme.textSmall.copyWith(color: Colors.black),
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 250,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onPressed: _selectPeriod,
                  icon: const Icon(Icons.date_range, size: 20),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedPeriod != null
                          ? '${DateFormat('MMM yyyy').format(selectedPeriod!.start)} - ${DateFormat('MMM yyyy').format(selectedPeriod!.end)}'
                          : 'Seleccionar Período',
                      style: AppTheme.textSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewSwitcher() {
    if (isMobile(context)) {
      return Column(
        children: [
          _buildFullWidthButton('overview', 'Dashboard General'),
          const SizedBox(height: 8),
          _buildFullWidthButton('consortium', 'Dashboard de Consorcio'),
          const SizedBox(height: 8),
          _buildFullWidthButton('unit', 'Dashboard de Unidad'),
        ],
      );
    } else {
      return Wrap(
        spacing: 8.0,
        alignment: WrapAlignment.center,
        children: [
          _buildViewButton('overview', 'Dashboard General'),
          _buildViewButton('consortium', 'Dashboard de Consorcio'),
          _buildViewButton('unit', 'Dashboard de Unidad'),
        ],
      );
    }
  }

  Widget _buildFullWidthButton(String view, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              currentView == view ? AppTheme.primaryColor : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          setState(() {
            currentView = view;
          });
        },
        child: Text(
          label,
          style: AppTheme.textSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildViewButton(String view, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            currentView == view ? AppTheme.primaryColor : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        setState(() {
          currentView = view;
        });
      },
      child:
          Text(label, style: AppTheme.textSmall.copyWith(color: Colors.white)),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> filteredData) {
    final summary = filteredData['summary'] ?? {};
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 2 : 1.2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildInfoCard('Total Ingresado', '\$${summary['totalIncome'] ?? 0}'),
        _buildInfoCard('Total en Gastos', '\$${summary['totalExpenses'] ?? 0}'),
        _buildInfoCard(
            'Gastos Pendientes de Pago', '\$${summary['totalPendingExpenses'] ?? 0}'),
      ],
    );
  }

  Widget _buildGraphSection(Map<String, dynamic> filteredData) {
    final graphData = filteredData['graphData'] ?? {};
    final expenseByMonth = (graphData['expenseByMonth'] ?? []) as List;
    final incomeByMonth = (graphData['incomeByMonth'] ?? []) as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gráficos de Flujo Monetario', style: AppTheme.titleMedium),
        const SizedBox(height: 16),
        _buildGraph('Gastos Mensuales', expenseByMonth, []),
        const SizedBox(height: 16),
        _buildGraph('Ingresos Mensuales', [], incomeByMonth),
      ],
    );
  }

Widget _buildConsortiumDetails(Map<String, dynamic> filteredData) {
  final consortiums = filteredData['consortiumSummary'] ?? [];
  final selectedConsortium = consortiums.firstWhere(
      (c) => c['consortiumID'] == selectedConsortiumID,
      orElse: () => null);

  final pendingExpensesData = _getPendingExpensesData(filteredData);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildConsortiumSelector(consortiums),
      const SizedBox(height: 16),
      if (selectedConsortium != null) ...[
        _buildConsortiumSummary(selectedConsortium),
        const SizedBox(height: 16),
        _buildGraph(
          'Gastos Mensuales',
          selectedConsortium['expenseByMonth'] ?? [],
          [],
        ),
        const SizedBox(height: 16),
        _buildGraph(
          'Ingresos Mensuales',
          [],
          selectedConsortium['incomeByMonth'] ?? [],
        ),
                const SizedBox(height: 16),
        _buildPendingExpensesChart(pendingExpensesData),

      ] else
        const Center(
            child: Text('Seleccione un consorcio para ver detalles')),
    ],
  );
}

  Widget _buildGraph(
      String title, List<dynamic> expenseData, List<dynamic> incomeData) {
    if (expenseData.isEmpty && incomeData.isEmpty) {
      return Card(
        color: AppTheme.lightBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: AppTheme.titleSmall),
              const SizedBox(height: 16),
              const Center(child: Text('Sin datos disponibles')),
            ],
          ),
        ),
      );
    }

    Map<String, double> expensesByMonth = {};
    Map<String, double> incomeByMonth = {};

    for (var item in expenseData) {
      final month = DateFormat('yyyy-MM').format(DateTime.parse(item['month']));
      expensesByMonth[month] = (item['total'] as num).toDouble();
    }

    for (var item in incomeData) {
      final month = DateFormat('yyyy-MM').format(DateTime.parse(item['month']));
      incomeByMonth[month] = (item['total'] as num).toDouble();
    }

    final allMonths = {
      ...expensesByMonth.keys,
      ...incomeByMonth.keys,
    }.toList()
      ..sort();

    List<FlSpot> expenseSpots = [];
    List<FlSpot> incomeSpots = [];
    List<String> xLabels = [];
    double minValue = 0;
    double maxValue = 0;

    for (int i = 0; i < allMonths.length; i++) {
      final month = allMonths[i];
      xLabels.add(DateFormat.MMM('es').format(DateTime.parse('$month-01')));

      final expenseValue = expensesByMonth[month] ?? 0.0;
      final incomeValue = incomeByMonth[month] ?? 0.0;

      expenseSpots.add(FlSpot(i.toDouble(), expenseValue));
      incomeSpots.add(FlSpot(i.toDouble(), incomeValue));

      minValue =
          [minValue, expenseValue, incomeValue].reduce((a, b) => a < b ? a : b);
      maxValue =
          [maxValue, expenseValue, incomeValue].reduce((a, b) => a > b ? a : b);
    }

    double adjustedMaxY = maxValue + (maxValue * 0.1);

    List<LineChartBarData> lines = [];
    if (title == 'Gastos Mensuales' && expenseSpots.isNotEmpty) {
      lines.add(
        LineChartBarData(
          spots: expenseSpots,
          isCurved: true,
          color: AppTheme.accentColor,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.accentColor.withOpacity(0.2),
          ),
        ),
      );
    }

    if (title == 'Ingresos Mensuales' && incomeSpots.isNotEmpty) {
      lines.add(
        LineChartBarData(
          spots: incomeSpots,
          isCurved: true,
          color: AppTheme.successColor,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.successColor.withOpacity(0.2),
          ),
        ),
      );
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.titleSmall.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: minValue < 0 ? minValue : 0,
                  maxY: adjustedMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (adjustedMaxY / 5).roundToDouble(),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              '\$${value.toInt()}',
                              style: AppTheme.textSmall.copyWith(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < xLabels.length) {
                            return Text(
                              xLabels[index],
                              style: AppTheme.textSmall.copyWith(fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    border: const Border(
                      left: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  lineBarsData: lines,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: AppTheme.primaryColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTheme.textMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.titleSmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildConsortiumSelector(List<dynamic> consortiums) {
  return DropdownButtonFormField<int>(
    decoration: const InputDecoration(
      labelText: 'Seleccione un consorcio',
      labelStyle: AppTheme.textSmall,
      filled: true,
      fillColor: AppTheme.lightBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
    ),
    value: selectedConsortiumID,
    items: consortiums.map<DropdownMenuItem<int>>((consortium) {
      return DropdownMenuItem<int>(
        value: consortium['consortiumID'],
        child: Text(consortium['name'], style: AppTheme.textSmall),
      );
    }).toList(),
    onChanged: (int? value) {
      setState(() {
        selectedConsortiumID = value;
        selectedUnitID = null;
      });
    },
  );
}


  Widget _buildConsortiumSummary(Map<String, dynamic> consortium) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              consortium['name'],
              style:
                  AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor),
            ),
            const Divider(thickness: 1.5),
            Text(
              'Balance: \$${consortium['balance'].toStringAsFixed(2)}',
              style: AppTheme.textMedium,
            ),
            Text(
              'Gastos Totales: \$${consortium['totalExpenses'].toStringAsFixed(2)}',
              style: AppTheme.textMedium,
            ),
            Text(
              'Pendientes: \$${consortium['pendingExpenses'].toStringAsFixed(2)}',
              style: AppTheme.textMedium,
            ),
          ],
        ),
      ),
    );
  }

Widget _buildUnitDashboard(Map<String, dynamic> filteredData) {
  final consortiums = filteredData['consortiumSummary'] ?? [];
  final selectedConsortium = consortiums.firstWhere(
    (c) => c['consortiumID'] == selectedConsortiumID,
    orElse: () => null,
  );
  final units = selectedConsortium != null ? selectedConsortium['units'] ?? [] : [];
  final selectedUnit = units.firstWhere(
    (u) => u['unitID'] == selectedUnitID,
    orElse: () => null,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildConsortiumSelector(consortiums),
      const SizedBox(height: 16),
      if (selectedConsortium == null) 
        const Center(
          child: Text(
            'Seleccione un consorcio para ver detalles',
            style: AppTheme.textMedium,
          ),
        )
      else ...[
        _buildUnitSelector(units),
        const SizedBox(height: 16),
        if (selectedUnit != null) ...[
          _buildUnitSummary(selectedUnit),
          const SizedBox(height: 16),
          _buildGraph(
            'Gastos Mensuales',
            selectedUnit['expenseByMonth'] ?? [],
            [],
          ),
          const SizedBox(height: 16),
          _buildGraph(
            'Ingresos Mensuales',
            [],
            selectedUnit['incomeByMonth'] ?? [],
          ),
        ] else
          const Center(
            child: Text(
              'Seleccione una unidad para ver detalles',
              style: AppTheme.textMedium,
            ),
          ),
      ],
    ],
  );
}

Widget _buildUnitSelector(List<dynamic> units) {
  return DropdownButtonFormField<int>(
    decoration: const InputDecoration(
      labelText: 'Seleccione una Propiedad',
      labelStyle: AppTheme.textSmall,
      filled: true,
      fillColor: AppTheme.lightBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
    ),
    value: selectedUnitID,
    items: units.map<DropdownMenuItem<int>>((unit) {
      return DropdownMenuItem<int>(
        value: unit['unitID'],
        child: Text(unit['name'], style: AppTheme.textSmall),
      );
    }).toList(),
    onChanged: (int? value) {
      setState(() {
        selectedUnitID = value;
      });
    },
  );
}

  Widget _buildUnitSummary(Map<String, dynamic> unit) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit['name'],
              style:
                  AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor),
            ),
            const Divider(thickness: 1.5),
            Text(
              'Balance: \$${unit['balance'].toStringAsFixed(2)}',
              style: AppTheme.textMedium,
            ),
            Text(
              'Propietarios: ${unit['ownersCount']}',
              style: AppTheme.textMedium,
            ),
            Text(
              'Inquilinos: ${unit['roomersCount']}',
              style: AppTheme.textMedium,
            ),
            Text(
              'Gastos Totales: \$${unit['totalExpenses'].toStringAsFixed(2)}',
              style: AppTheme.textMedium,
            ),
            Text(
              'Pendientes: \$${unit['pendingExpenses'].toStringAsFixed(2)}',
              style: AppTheme.textMedium,
            ),
          ],
        ),
      ),
    );
  }

Widget _buildPendingExpensesChart(List<Map<String, dynamic>> pendingExpensesData) {
  if (pendingExpensesData.isEmpty) {
    return const Center(
      child: Text(
        'No hay gastos pendientes.',
        style: AppTheme.textMedium,
      ),
    );
  }

  final totalPending = pendingExpensesData
      .map((e) => e['pendingExpenses'] as double)
      .reduce((a, b) => a + b);


  Color getGradientColor(double percentage) {
    return Color.lerp(
      AppTheme.primaryColor,
      AppTheme.accentColor,
      percentage,
    )!;
  }

  return Card(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: AppTheme.lightBackground,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Gastos Pendientes',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: pendingExpensesData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final unit = entry.value;
                      final value = unit['pendingExpenses'] as double;

                      return PieChartSectionData(
                        value: value,
                        title: '${unit['name']}',
                        titleStyle: AppTheme.textSmallBold.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        radius: 90,
                        color: getGradientColor(index / pendingExpensesData.length),
                      );
                    }).toList(),
                    sectionsSpace: 6,
                    centerSpaceRadius: 70,
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          '\$${totalPending.toStringAsFixed(2)}',
                          style: AppTheme.textBold.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        'Total Pendiente',
                        style: AppTheme.textSmall.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: pendingExpensesData.asMap().entries.map((entry) {
              final index = entry.key;
              final unit = entry.value;
              final value = unit['pendingExpenses'] as double;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: getGradientColor(index / pendingExpensesData.length),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${unit['name']} (\$${value.toStringAsFixed(2)})',
                    style: AppTheme.textSmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}


}
