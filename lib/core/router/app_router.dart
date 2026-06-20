import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/auth/services/user_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/account_profile_screen.dart';
import '../../features/student/screens/university_verification_screen.dart';
import '../../features/student/screens/qr_id_screen.dart';
import '../../features/student/screens/qr_scanner_screen.dart';
import '../../features/student/screens/transaction_history_screen.dart';
import '../../features/vendor/presentation/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/vendor_create_payment_request_screen.dart';
import '../../features/vendor/presentation/vendor_qr_payment_screen.dart';
import '../../features/vendor/presentation/vendor_offers_screen.dart';
import '../../features/vendor/presentation/vendor_transaction_history_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_manage_vendors_screen.dart';
import '../../features/wallet/presentation/user_wallet_screen.dart';
import '../../features/offers/presentation/user_offers_screen.dart';
import '../../features/points_rewards/presentation/user_points_rewards_screen.dart';
import '../../features/settings/presentation/user_settings_screen.dart';
import '../../features/events/presentation/user_events_screen.dart';
import '../../features/admin/presentation/admin_settings_screen.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/admin/presentation/admin_transactions_screen.dart';
import '../../features/admin/presentation/admin_offers_screen.dart';
import '../../features/admin/presentation/admin_events_screen.dart';
import '../../features/admin/presentation/admin_vendor_details_screen.dart';

class AppRouter {
  static final _authNotifier = _AuthStateNotifier();
  static final _userService = UserService();
  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _authNotifier,
    redirect: (BuildContext context, GoRouterState state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final loc = state.matchedLocation;
      final isPublicRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/email-verification';
      if (!isLoggedIn && !isPublicRoute) return '/login';
      if (isLoggedIn && isPublicRoute && loc != '/email-verification') {
        final userModel = await _userService.getUserDocument(user.uid);
        final role = userModel?.role ?? UserRole.normalUser;
        if (role == UserRole.vendor) return '/vendor';
        if (role == UserRole.admin) return '/admin';
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/email-verification', builder: (context, state) => const EmailVerificationScreen()),
      GoRoute(path: '/home', builder: (context, state) => const StudentDashboardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const AccountProfileScreen()),
      GoRoute(path: '/verify', builder: (context, state) => const UniversityVerificationScreen()),
      GoRoute(path: '/qr-id', builder: (context, state) => const QrIdScreen()),
      GoRoute(path: '/qr-scanner', builder: (context, state) => const QrScannerScreen()),
      GoRoute(path: '/transactions', builder: (context, state) => const TransactionHistoryScreen()),
      GoRoute(path: '/wallet', builder: (context, state) => const UserWalletScreen()),
      GoRoute(path: '/offers', builder: (context, state) => const UserOffersScreen()),
      GoRoute(path: '/rewards', builder: (context, state) => const UserPointsRewardsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const UserSettingsScreen()),
      GoRoute(path: '/vendor', builder: (context, state) => const VendorDashboardScreen()),
      GoRoute(path: '/vendor/payment-request', builder: (context, state) => const VendorCreatePaymentRequestScreen()),
      GoRoute(path: '/vendor/qr', builder: (context, state) => const VendorQrPaymentScreen()),
      GoRoute(path: '/vendor/offers', builder: (context, state) => const VendorOffersScreen()),
      GoRoute(path: '/vendor/transactions', builder: (context, state) => const VendorTransactionHistoryScreen()),
      GoRoute(path: '/vendor/profile', builder: (context, state) => const AccountProfileScreen()),
      GoRoute(path: '/events', builder: (context, state) => const UserEventsScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/vendors', builder: (context, state) => const AdminManageVendorsScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
      GoRoute(path: '/admin/transactions', builder: (context, state) => const AdminTransactionsScreen()),
      GoRoute(path: '/admin/offers', builder: (context, state) => const AdminOffersScreen()),
      GoRoute(path: '/admin/events', builder: (context, state) => const AdminEventsScreen()),
      GoRoute(path: '/admin/settings', builder: (context, state) => const AdminSettingsScreen()),
      GoRoute(path: '/admin/vendor-details', builder: (context, state) => const AdminVendorDetailsScreen()),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}
