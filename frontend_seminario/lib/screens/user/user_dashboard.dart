import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:go_router/go_router.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  UserDashboardState createState() => UserDashboardState();
}

class UserDashboardState extends State<UserDashboard> {
  final StorageService storageService = StorageService();
  List<dynamic> _units = [];
  bool _isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserUnits();
  }

  Future<void> _fetchUserData() async {
    final user = await storageService.getUserData();
    if (user != null) {
      setState(() {
        userName = '${user['name']} ${user['surname']}';
      });
    }
  }

  Future<void> _fetchUserUnits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await storageService.getUserData();
      if (user != null) {
        final userId = user['ID'];
        final response = await UserApiService.getUnitsByUser(userId);
        if (response.statusCode == 200) {
          setState(() {
            _units = jsonDecode(response.body);
            _isLoading = false;
          });
        } else {
          print('Error fetching user units: ${response.body}');
          setState(() {
            _isLoading = false;
          });
        }
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
      title: 'Dashboard de Usuario',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _units.isEmpty
              ? const Center(child: Text('No hay unidades asociadas al usuario, contacte a su administrador'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width < 600 ? 2 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _units.length,
                    itemBuilder: (context, index) {
                      var unit = _units[index];
                      return GestureDetector(
                        onTap: () {
                          context.go('/user/unit/${unit['ID']}');
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.home,
                                    size: 80,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      unit['name'],
                                      style: AppTheme.textMedium.copyWith(
                                          color: AppTheme.primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Consorcio: ${unit['consortium']['name']}',
                                      style: AppTheme.textSmall.copyWith(
                                          color: AppTheme.primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      isAdmin: false,
      storageService: storageService,
    );
  }
}
