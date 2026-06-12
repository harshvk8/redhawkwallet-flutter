import 'package:go_router/go_router.dart';

import 'package:redhawkwallet_flutter/features/student/screens/account_profile_screen.dart';
import 'package:redhawkwallet_flutter/features/student/screens/student_dashboard_screen.dart';
import 'package:redhawkwallet_flutter/features/student/screens/login_screen.dart';
import 'package:redhawkwallet_flutter/features/student/screens/university_verification_screen.dart';
import 'package:redhawkwallet_flutter/features/student/screens/qr_id_screen.dart';
import 'package:redhawkwallet_flutter/features/student/screens/qr_scanner_screen.dart';
import 'package:redhawkwallet_flutter/features/student/screens/transaction_history_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (context, state) => const StudentDashboardScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const AccountProfileScreen(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) => const UniversityVerificationScreen(),
    ),
    GoRoute(path: '/qr-id', builder: (context, state) => const QrIdScreen()),
    GoRoute(
      path: '/qr-scanner',
      builder: (context, state) => const QrScannerScreen(),
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
  ],
);
