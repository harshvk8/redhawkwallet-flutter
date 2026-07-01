import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/account_profile_screen.dart';
import '../../features/student/screens/university_verification_screen.dart';
import '../../features/student/screens/qr_id_screen.dart';
import '../../features/student/screens/qr_scanner_screen.dart';
import '../../features/student/screens/transaction_history_screen.dart';
import '../../features/student/screens/transaction_detail_screen.dart';
import '../../features/student/models/demo_transaction.dart';
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
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/events/presentation/user_events_screen.dart';
import '../../features/admin/presentation/admin_settings_screen.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/admin/presentation/admin_transactions_screen.dart';
import '../../features/admin/presentation/admin_offers_screen.dart';
import '../../features/admin/presentation/admin_events_screen.dart';
import '../../features/admin/presentation/admin_vendor_details_screen.dart';
import '../../features/admin/presentation/admin_reports_screen.dart';
import '../../features/admin/presentation/admin_transaction_details_screen.dart';
import '../../features/admin/presentation/reported_issues_screen.dart';
import '../../features/vendor/presentation/vendor_waiting_approval_screen.dart';
import '../../features/vendor/presentation/vendor_profile_screen.dart';
import '../../features/vendor/presentation/edit_vendor_profile_screen.dart';
import '../../features/vendor/presentation/vendor_sales_report_screen.dart';
import '../../features/wallet/presentation/add_money_screen.dart';
import '../../features/legal/presentation/terms_screen.dart';
import '../../features/legal/presentation/privacy_policy_screen.dart';
import '../../features/legal/presentation/vendor_terms_screen.dart';

class AppRouter {
  static final _authNotifier = _AuthStateNotifier();
  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final isPublicRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/email-verification';

      if (!isLoggedIn) {
        return isPublicRoute ? null : '/login';
      }

      // Role not yet fetched — stay on splash while Firestore loads
      if (_authNotifier.role == null) return '/splash';

      final role = _authNotifier.role!;

      // Suspended accounts can't proceed past login
      if (_authNotifier.accountStatus == 'suspended') return '/login';

      // Vendor status gate — pending vendors only reach /vendor/waiting
      if (role == UserRole.vendor) {
        final vStatus = _authNotifier.vendorStatus;
        if (vStatus != 'approved' && loc != '/vendor/waiting') return '/vendor/waiting';
        if (vStatus == 'approved' && loc == '/vendor/waiting') return '/vendor';
      }

      // Once role is known, redirect off splash or public routes to correct dashboard
      if (loc == '/splash' || isPublicRoute) {
        return _homeForRole(role);
      }

      // Prevent cross-role access
      if (_isRoleRestrictedRoute(loc)) {
        if (loc.startsWith('/vendor') && role != UserRole.vendor) return _homeForRole(role);
        if (loc.startsWith('/admin') && role != UserRole.admin) return _homeForRole(role);
        if (_isStudentRoute(loc) && role == UserRole.vendor) return '/vendor';
        if (_isStudentRoute(loc) && role == UserRole.admin) return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/email-verification', builder: (context, state) => const EmailVerificationScreen()),
      GoRoute(path: '/home', builder: (context, state) => const StudentDashboardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const AccountProfileScreen()),
      GoRoute(path: '/verify', builder: (context, state) => const UniversityVerificationScreen()),
      GoRoute(path: '/qr-id', builder: (context, state) => const QrIdScreen()),
      GoRoute(path: '/qr-scanner', builder: (context, state) => const QrScannerScreen()),
      GoRoute(path: '/transactions', builder: (context, state) => const TransactionHistoryScreen()),
      GoRoute(
        path: '/transaction-detail',
        builder: (context, state) =>
            TransactionDetailScreen(transaction: state.extra! as DemoTransaction),
      ),
      GoRoute(path: '/wallet', builder: (context, state) => const UserWalletScreen()),
      GoRoute(path: '/offers', builder: (context, state) => const UserOffersScreen()),
      GoRoute(path: '/rewards', builder: (context, state) => const UserPointsRewardsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const UserSettingsScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/vendor', builder: (context, state) => const VendorDashboardScreen()),
      GoRoute(path: '/vendor/waiting', builder: (context, state) => const VendorWaitingApprovalScreen()),
      GoRoute(path: '/vendor/profile', builder: (context, state) => const VendorProfileScreen()),
      GoRoute(path: '/vendor/profile/edit', builder: (context, state) => const EditVendorProfileScreen()),
      GoRoute(path: '/vendor/sales-report', builder: (context, state) => const VendorSalesReportScreen()),
      GoRoute(path: '/vendor/payment-request', builder: (context, state) => const VendorCreatePaymentRequestScreen()),
      GoRoute(path: '/vendor/qr', builder: (context, state) => const VendorQrPaymentScreen()),
      GoRoute(path: '/vendor/offers', builder: (context, state) => const VendorOffersScreen()),
      GoRoute(path: '/vendor/transactions', builder: (context, state) => const VendorTransactionHistoryScreen()),
      GoRoute(path: '/events', builder: (context, state) => const UserEventsScreen()),
      GoRoute(path: '/wallet/add-money', builder: (context, state) => const AddMoneyScreen()),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(path: '/privacy', builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: '/vendor-terms', builder: (context, state) => const VendorTermsScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/vendors', builder: (context, state) => const AdminManageVendorsScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
      GoRoute(path: '/admin/transactions', builder: (context, state) => const AdminTransactionsScreen()),
      GoRoute(path: '/admin/transaction-details', builder: (context, state) => const AdminTransactionDetailsScreen()),
      GoRoute(path: '/admin/offers', builder: (context, state) => const AdminOffersScreen()),
      GoRoute(path: '/admin/events', builder: (context, state) => const AdminEventsScreen()),
      GoRoute(path: '/admin/settings', builder: (context, state) => const AdminSettingsScreen()),
      GoRoute(path: '/admin/vendor-details', builder: (context, state) => const AdminVendorDetailsScreen()),
      GoRoute(path: '/admin/reports', builder: (context, state) => const AdminReportsScreen()),
      GoRoute(path: '/admin/reported-issues', builder: (context, state) => const ReportedIssuesScreen()),
    ],
  );

  static bool _isRoleRestrictedRoute(String location) => _isStudentRoute(location) || location.startsWith('/vendor') || location.startsWith('/admin');

  static bool _isStudentRoute(String location) {
    return location == '/home' ||
        location == '/profile' ||
        location == '/verify' ||
        location == '/qr-id' ||
        location == '/qr-scanner' ||
        location == '/transactions' ||
        location == '/wallet' ||
        location == '/offers' ||
        location == '/rewards' ||
        location == '/settings' ||
        location == '/events';
  }

  static String _homeForRole(String role) {
    if (role == UserRole.vendor) return '/vendor';
    if (role == UserRole.admin) return '/admin';
    return '/home';
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AuthStateNotifier extends ChangeNotifier {
  String? _role;
  String? _vendorStatus;
  String? _accountStatus;

  String? get role => _role;
  String? get vendorStatus => _vendorStatus;
  String? get accountStatus => _accountStatus;

  _AuthStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        _role = null;
        _vendorStatus = null;
        _accountStatus = null;
        notifyListeners();
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      _role = data['role'] as String? ?? UserRole.normalUser;
      _vendorStatus = data['vendorStatus'] as String?;
      _accountStatus = data['accountStatus'] as String?;
      notifyListeners();
    });
  }
}