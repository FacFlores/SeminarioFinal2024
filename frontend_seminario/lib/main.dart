import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:frontend_seminario/routes/app_router.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AppRouter appRouter = AppRouter(StorageService());
  final storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Gestión de Consorcio',
      theme: AppTheme.themeData,
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), 
        Locale('es', 'ES'), 
      ],
      locale: const Locale('es', 'ES'), 
    );
  }
}
