import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/auth/services/user_service.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/account_profile_screen.dart';
import '../../features/student/screens/university_verification_screen.dart';
import '../../features/student/screens/qr_id_screen.dart';
import '../../features/student/screens/qr_scanner_screen.dart';
import '../../features/student/screens/transaction_history_screen.dart';
import '../../features/vendor/presentation/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/vendor_create_payment_request_screen.dart';
import '../../features/vendor/presentation/vendor_qr_payment_screen.dart';
import '../../features/vendor/presentation/vendor_transaction_history_screen.dart';
import '../../features/vendor/presentation/vendor_offers_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_manage_vendors_screen.dart';

class AppRouter {
  static final _stateNotifier = _AppStateNotifier();

  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _stateNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;

      final isPublicRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/email-verification';

      // Not logged in → force to login
      if (!isLoggedIn && !isPublicRoute) return '/login';

      // Logged in but role is still being fetched → wait (redirect fires again
      // once notifier calls notifyListeners after the Firestore fetch completes)
      if (isLoggedIn && _stateNotifier.loading) return null;

      // Logged in and on a public route → send to role-based home
      if (isLoggedIn && isPublicRoute) {
        return _homeForRole(_stateNotifier.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      // Student routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const AccountProfileScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) => const UniversityVerificationScreen(),
      ),
      GoRoute(
        path: '/qr-id',
        builder: (context, state) => const QrIdScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      // Vendor routes
      GoRoute(
        path: '/vendor',
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: '/vendor/payment-request',
        builder: (context, state) => const VendorCreatePaymentRequestScreen(),
      ),
      GoRoute(
        path: '/vendor/qr',
        builder: (context, state) => const VendorQrPaymentScreen(),
      ),
      GoRoute(
        path: '/vendor/transactions',
        builder: (context, state) => const VendorTransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/vendor/offers',
        builder: (context, state) => const VendorOffersScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/vendors',
        builder: (context, state) => const AdminManageVendorsScreen(),
      ),
    ],
  );

  static String _homeForRole(String? role) {
    if (role == UserRole.vendor) return '/vendor';
    if (role == UserRole.admin) return '/admin';
    return '/home';
  }
}

class _AppStateNotifier extends ChangeNotifier {
  String? _role;
  bool _loading = false;

  String? get role => _role;
  bool get loading => _loading;

  _AppStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        _role = null;
        _loading = false;
        notifyListeners();
        return;
      }
      _loading = true;
      notifyListeners();
      final doc = await UserService().getUserDocument(user.uid);
      _role = doc?.role;
      _loading = false;
      notifyListeners();
    });
  }
}
