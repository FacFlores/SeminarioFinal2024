import 'package:frontend_seminario/screens/admin/admin_notification.dart';
import 'package:frontend_seminario/screens/admin/assign_coefficients_page.dart';
import 'package:frontend_seminario/screens/admin/consortiums/consortium_list_page.dart';
import 'package:frontend_seminario/screens/admin/consortiums/consortium_units_page.dart';
import 'package:frontend_seminario/screens/admin/liquidation_page.dart';
import 'package:frontend_seminario/screens/admin/manage_coefficients_page.dart';
import 'package:frontend_seminario/screens/admin/manage_concepts_page.dart';
import 'package:frontend_seminario/screens/admin/manage_expenses_page.dart';
import 'package:frontend_seminario/screens/admin/manual_payment_page.dart';
import 'package:frontend_seminario/screens/admin/owner_roomer_managment_page.dart';
import 'package:frontend_seminario/screens/admin/automatic_payment_page.dart';
import 'package:frontend_seminario/screens/admin/unit_ledger_page.dart';
import 'package:frontend_seminario/screens/admin/user_managment_page.dart';
import 'package:frontend_seminario/screens/user/pdf_generation_page.dart';
import 'package:frontend_seminario/screens/user/pending_expenses_page.dart';
import 'package:frontend_seminario/screens/user/unit_detail_page.dart';
import 'package:frontend_seminario/screens/user/user_notification.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend_seminario/screens/login_screen.dart';
import 'package:frontend_seminario/screens/register_screen.dart';
import 'package:frontend_seminario/screens/admin/admin_dashboard.dart';
import 'package:frontend_seminario/screens/user/user_dashboard.dart';
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
        return admin ? '/admin' : '/user';
      }
      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        redirect: (context, state) async {
          final tokenValid = await _storageService.checkTokenValidity();
          final loggedIn = tokenValid && await _isLoggedIn();
          final admin = await _isAdmin();

          if (loggedIn) {
            return admin ? '/admin' : '/user';
          }
          return null;
        },
      ),

      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
        redirect: (context, state) async {
          final tokenValid = await _storageService.checkTokenValidity();
          final loggedIn = tokenValid && await _isLoggedIn();
          final admin = await _isAdmin();

          if (loggedIn) {
            return admin ? '/admin' : '/user';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => const UserDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/consortiums',
        builder: (context, state) => const ConsortiumListPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/people',
        builder: (context, state) => const OwnerRoomerManagementPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/consortiums/:consortiumId/units',
        builder: (context, state) {
          final consortiumId = int.parse(state.pathParameters['consortiumId']!);
          return ConsortiumUnitsPage(consortiumId: consortiumId);
        },
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),

      GoRoute(
        path: '/admin/concepts',
        builder: (context, state) => const ManageConceptsPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/coefficients',
        builder: (context, state) => const ManageCoefficientsPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/unit-coefficients',
        builder: (context, state) => const AssignCoefficientsPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/expenses',
        builder: (context, state) => const ManageExpensesPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/liquidations',
        builder: (context, state) => const LiquidationPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/payments/manual',
        builder: (context, state) => const ManualPaymentPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/payments/automatic',
        builder: (context, state) => const AutomaticPaymentPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/unit-balances',
        builder: (context, state) => const UnitLedgerPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),

      GoRoute(
        path: '/user/unit/:unitId',
        builder: (context, state) {
          final unitId = int.parse(state.pathParameters['unitId']!);
          return UnitDetail(unitId: unitId);
        },
      ),

      GoRoute(
        path: '/user/pending-expenses',
        builder: (context, state) => const PendingExpensesPage(),
        redirect: (context, state) async {
          final user = await _storageService.getUserData();
          return user != null ? null : '/login';
        },
      ),
      GoRoute(
        path: '/user/documents',
        builder: (context, state) => const PdfGenerationPage(),
        redirect: (context, state) async {
          final user = await _storageService.getUserData();
          return user != null ? null : '/login';
        },
      ),

      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsPage(),
        redirect: (context, state) async {
          final admin = await _isAdmin();
          if (!admin) {
            return '/';
          }
          return null;
        },
      ),

      GoRoute(
        path: '/user/notifications',
        builder: (context, state) => const UserNotificationsPage(),
        redirect: (context, state) async {
          final user = await _storageService.getUserData();
          return user != null ? null : '/login';
        },
      ),

      // Fallback route for unknown paths
      GoRoute(
        path: '/:splat',
        builder: (context, state) => const LoginScreen(),
        redirect: (context, state) async {
          final tokenValid = await _storageService.checkTokenValidity();
          final loggedIn = tokenValid && await _isLoggedIn();
          final admin = await _isAdmin();

          if (loggedIn) {
            return admin ? '/admin' : '/user';
          }
          return null;
        },
      ),
    ],
  );
}
