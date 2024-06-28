import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/routes/app_router.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AppRouter appRouter = AppRouter(StorageService());
  final storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Gestion de Consorcio',
      theme: AppTheme.themeData,
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
    );
  }
}
