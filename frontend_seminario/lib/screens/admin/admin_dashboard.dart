import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/admin_api_service.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/owner_api_service.dart';
import 'package:frontend_seminario/services/api/roomer_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final StorageService storageService = StorageService();
  bool isLoading = true;
  int totalConsortiums = 0;
  int totalUnits = 0;
  int totalAdmins = 0;
  int totalUsers = 0;
  int activeUsers = 0;
  int inactiveUsers = 0;
  int totalOwnersAndRoomers = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final consortiumsResponse =
          await ConsortiumApiService.getAllConsortiums();
      final unitsResponse = await UnitApiService.getAllUnits();
      final adminsResponse = await AdminApiService.getAllAdmins();
      final usersResponse = await UserApiService.getAllUsers();
      final activeUsersResponse = await UserApiService.getActiveUsers();
      final inactiveUsersResponse = await UserApiService.getInactiveUsers();
      final ownersResponse = await OwnersApiService.getAllOwners();
      final roomersResponse = await RoomerApiService.getAllRoomers();

      setState(() {
        totalConsortiums = jsonDecode(consortiumsResponse.body).length;
        totalUnits = jsonDecode(unitsResponse.body).length;
        totalAdmins = jsonDecode(adminsResponse.body).length;
        totalUsers = jsonDecode(usersResponse.body).length;
        activeUsers = jsonDecode(activeUsersResponse.body).length;
        inactiveUsers = jsonDecode(inactiveUsersResponse.body).length;
        totalOwnersAndRoomers = jsonDecode(ownersResponse.body).length +
            jsonDecode(roomersResponse.body).length;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors appropriately here
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Dashboard Administrativo',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Admin!',
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoGrid(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
      isAdmin: true,
      storageService: storageService,
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildInfoCard('Total Consortiums', totalConsortiums.toString()),
        _buildInfoCard('Total Units', totalUnits.toString()),
        _buildInfoCard(
            'Total Owners + Roomers', totalOwnersAndRoomers.toString()),
        _buildInfoCard('Total Users',
            '$totalUsers (Active: $activeUsers, Inactive: $inactiveUsers)'),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: AppTheme.primaryColor,
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

  Widget _buildActionButtons() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildActionButton(
            'Create Consortium', Icons.add_business, '/create-consortium'),
        _buildActionButton('Create Unit', Icons.add_home, '/create-unit'),
        _buildActionButton(
            'Create Owner/Roomer', Icons.person_add, '/create-owner-roomer'),
        _buildActionButton(
            'Create User', Icons.person_add_alt_1, '/create-user'),
        _buildActionButton(
            'Create Expense', Icons.add_shopping_cart, '/create-expense'),
        _buildActionButton('Create Payment', Icons.payment, '/create-payment'),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          context.go(route);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppTheme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
