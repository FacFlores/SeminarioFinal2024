import 'package:flutter/material.dart';
import 'package:frontend_seminario/screens/login_screen.dart';
import 'package:frontend_seminario/screens/register_screen.dart';
import 'package:frontend_seminario/screens/admin_dashboard.dart';
import 'package:frontend_seminario/screens/user_dashboard.dart';
import 'package:frontend_seminario/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env.development");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestion de Consorcio',
      theme: AppTheme.themeData,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/user-dashboard': (context) => const UserDashboard(),
      },
    );
  }
}
