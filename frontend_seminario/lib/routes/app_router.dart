import 'package:go_router/go_router.dart';
import 'package:frontend_seminario/screens/login_screen.dart';
import 'package:frontend_seminario/screens/register_screen.dart';
import 'package:frontend_seminario/screens/admin_dashboard.dart';
import 'package:frontend_seminario/screens/user_dashboard.dart';
import 'package:frontend_seminario/screens/admin_settings_page.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class AppRouter {
  final StorageService _storageService;

  AppRouter(this._storageService);

  Future<bool> _isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null;
  }

  Future<bool> _isAdmin() async {
    final user = await _storageService.getUserData();
    return user?['role']['name'] == 'Admin';
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final tokenValid = await _storageService.checkTokenValidity();
      final loggedIn = tokenValid && await _isLoggedIn();
      final admin = await _isAdmin();
      final loggingIn = state.matchedLocation == '/login';
      final registering = state.matchedLocation == '/register';

      if (!loggedIn) {
        return loggingIn || registering ? null : '/login';
      }

      if (loggingIn || registering) {
        return admin ? '/admin-dashboard' : '/user-dashboard';
      }

      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/user-dashboard',
        builder: (context, state) => const UserDashboard(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          return admin ? null : '/login';
        },
      ),
      GoRoute(
        path: '/admin-settings',
        builder: (context, state) => const AdminSettingsPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          return admin ? null : '/login';
        },
      ),
      // Fallback route for unknown paths
      GoRoute(
        path: '/*',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
