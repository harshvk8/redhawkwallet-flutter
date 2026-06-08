import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/account_profile_screen.dart';
import '../../features/student/screens/university_verification_screen.dart';
import '../../features/student/screens/qr_id_screen.dart';
import '../../features/student/screens/qr_scanner_screen.dart';
import '../../features/student/screens/transaction_history_screen.dart';
import '../../features/vendor/screens/vendor_dashboard_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';

class AppRouter {
  static final _authNotifier = _AuthStateNotifier();

  static final router = GoRouter(
    // Determine initial location based on current auth state so a logged-in
    // user skips the login screen on cold start.
    initialLocation:
        FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
    refreshListenable: _authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;

      // Public routes that don't require auth
      final isPublicRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/email-verification';

      // Not logged in and trying to reach a protected route → login
      if (!isLoggedIn && !isPublicRoute) return '/login';

      // Logged in and at a protected route → no redirect; screens handle
      // post-login navigation themselves so role-based routing works.
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
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}
