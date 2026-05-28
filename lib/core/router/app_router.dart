import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/account_profile_screen.dart';
import '../../features/student/screens/university_verification_screen.dart';
import '../../features/student/screens/qr_id_screen.dart';
import '../../features/student/screens/qr_scanner_screen.dart';
import '../../features/student/screens/transaction_history_screen.dart';
import '../../features/vendor/presentation/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/vendor_offers_screen.dart';
import '../../features/vendor/presentation/vendor_create_payment_request_screen.dart';
import '../../features/vendor/presentation/vendor_qr_payment_screen.dart';
import '../../features/vendor/presentation/vendor_transaction_history_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_manage_vendors_screen.dart';

class AppRouter {
  static final _authNotifier = _AuthStateNotifier();

  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
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
      GoRoute(
        path: '/vendor',
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: '/vendor/offers',
        builder: (context, state) => const VendorOffersScreen(),
      ),
      GoRoute(
        path: '/vendor/payment-request',
        builder: (context, state) => const VendorCreatePaymentRequestScreen(),
      ),
      GoRoute(
        path: '/vendor/qr-payment',
        builder: (context, state) => const VendorQrPaymentScreen(),
      ),
      GoRoute(
        path: '/vendor/history',
        builder: (context, state) => const VendorTransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/manage-vendors',
        builder: (context, state) => const AdminManageVendorsScreen(),
      ),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}
