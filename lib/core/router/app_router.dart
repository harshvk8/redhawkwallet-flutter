import 'dart:async';

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
import '../../features/student/screens/edit_profile_screen.dart';
import '../../features/student/screens/university_verification_screen.dart';
import '../../features/student/screens/qr_id_screen.dart';
import '../../features/student/screens/qr_scanner_screen.dart';
import '../../features/student/screens/transaction_history_screen.dart';
import '../../features/vendor/presentation/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/vendor_create_payment_request_screen.dart';
import '../../features/vendor/presentation/vendor_list_screen.dart';
import '../../features/vendor/presentation/vendor_details_screen.dart';
import '../../features/vendor/presentation/vendor_qr_payment_screen.dart';
import '../../features/vendor/presentation/vendor_offers_screen.dart';
import '../../features/vendor/presentation/vendor_transaction_history_screen.dart';
import '../../features/vendor/presentation/vendor_waiting_approval_screen.dart';
import '../../features/vendor/presentation/vendor_profile_screen.dart';
import '../../features/vendor/presentation/edit_vendor_profile_screen.dart';
import '../../features/vendor/presentation/payment_received_screen.dart';
import '../../features/vendor/presentation/vendor_sales_report_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_manage_vendors_screen.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/admin/presentation/admin_transactions_screen.dart';
import '../../features/admin/presentation/admin_offers_screen.dart';
import '../../features/admin/presentation/admin_events_screen.dart';
import '../../features/admin/presentation/admin_settings_screen.dart';
import '../../features/admin/presentation/admin_vendor_details_screen.dart';
import '../../features/admin/presentation/admin_transaction_details_screen.dart';
import '../../features/admin/presentation/admin_reports_screen.dart';
import '../../features/admin/presentation/reported_issues_screen.dart';
import '../../features/wallet/presentation/user_wallet_screen.dart';
import '../../features/wallet/presentation/add_money_screen.dart';
import '../../features/wallet/presentation/send_money_screen.dart';
import '../../features/wallet/presentation/receive_money_screen.dart';
import '../../features/wallet/presentation/pay_vendor_screen.dart';
import '../../features/wallet/presentation/transaction_details_screen.dart';
import '../../features/offers/presentation/user_offers_screen.dart';
import '../../features/points_rewards/presentation/user_points_rewards_screen.dart';
import '../../features/settings/presentation/user_settings_screen.dart';
import '../../features/settings/presentation/security_settings_screen.dart';
import '../../features/events/presentation/user_events_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/legal/presentation/terms_screen.dart';
import '../../features/legal/presentation/privacy_policy_screen.dart';
import '../../features/legal/presentation/vendor_terms_screen.dart';
import '../../features/support/presentation/support_chat_screen.dart';
import '../../features/admin/presentation/admin_support_chats_screen.dart';
import '../../features/admin/presentation/admin_support_chat_detail_screen.dart';

class AppRouter {
  static final _authNotifier = _AuthStateNotifier();
  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      
      // Auth routes: redirect logged-in users away to their dashboard.
      final isAuthRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/email-verification';

      // Legal routes: always viewable, logged in or not.
      final isLegalRoute =
          loc == '/terms' || loc == '/privacy' || loc == '/vendor-terms';

      if (!isLoggedIn) {
        return (isAuthRoute || isLegalRoute) ? null : '/login';
      }

      // Role/status not yet fetched — stay on splash while Firestore loads
      if (_authNotifier.role == null) return '/splash';

      if (_authNotifier.accountStatus == 'suspended') {
        FirebaseAuth.instance.signOut();
        return '/login';
      }

      // Email verification gate: signed-in but unverified users are confined
      // to the verification screen until they confirm their email.
      if (!_authNotifier.isEmailVerified) {
        return loc == '/email-verification' || isLegalRoute ? null : '/email-verification';
      }

      final role = _authNotifier.role!;
      final isPendingVendor =
          role == UserRole.vendor && _authNotifier.vendorStatus != 'approved';

      // Once role is known, redirect off splash or auth routes to correct dashboard
      if (loc == '/splash' || isAuthRoute) {
        if (isPendingVendor) return '/vendor/waiting';
        if (role == UserRole.vendor) return '/vendor';
        if (role == UserRole.admin) return '/admin';
        return '/home';
      }

      if (isLegalRoute) return null;

      // Pending vendors are confined to the waiting screen until approved,
      // except support chat — they may still need help while waiting.
      if (isPendingVendor && loc != '/vendor/waiting' && loc != '/support') {
        return '/vendor/waiting';
      }

      // Prevent cross-role access. Exact-match the bare prefix or require a
      // trailing slash — loc.startsWith('/vendor') would also match the
      // student-facing '/vendors' (Browse Vendors) route and incorrectly
      // treat it as vendor-role-only.
      final isVendorRoute = loc == '/vendor' || loc.startsWith('/vendor/');
      final isAdminRoute = loc == '/admin' || loc.startsWith('/admin/');
      if (isVendorRoute && role != UserRole.vendor) return '/home';
      if (isAdminRoute && role != UserRole.admin) return '/home';

      // Role changed live while sitting on a student route — move to correct dashboard.
      if (!isVendorRoute && !isAdminRoute) {
        if (role == UserRole.vendor) return '/vendor';
        if (role == UserRole.admin) return '/admin';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('No route for "${state.uri}"'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/email-verification', builder: (context, state) => const EmailVerificationScreen()),
      GoRoute(path: '/home', builder: (context, state) => const StudentDashboardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const AccountProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/verify', builder: (context, state) => const UniversityVerificationScreen()),
      GoRoute(path: '/qr-id', builder: (context, state) => const QrIdScreen()),
      GoRoute(path: '/qr-scanner', builder: (context, state) => const QrScannerScreen()),
      GoRoute(path: '/transactions', builder: (context, state) => const TransactionHistoryScreen()),
      GoRoute(path: '/transaction-details', builder: (context, state) => const TransactionDetailsScreen()),
      GoRoute(path: '/wallet', builder: (context, state) => const UserWalletScreen()),
      GoRoute(path: '/wallet/add', builder: (context, state) => const AddMoneyScreen()),
      GoRoute(path: '/wallet/send', builder: (context, state) => const SendMoneyScreen()),
      GoRoute(path: '/wallet/receive', builder: (context, state) => const ReceiveMoneyScreen()),
      GoRoute(
        path: '/wallet/pay-vendor', 
        builder: (context, state) => PayVendorScreen(vendor: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(path: '/wallet/pay', builder: (context, state) => const PayVendorScreen()),
      GoRoute(path: '/offers', builder: (context, state) => const UserOffersScreen()),
      GoRoute(path: '/rewards', builder: (context, state) => const UserPointsRewardsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const UserSettingsScreen()),
      GoRoute(path: '/settings/security', builder: (context, state) => const SecuritySettingsScreen()),
      GoRoute(path: '/events', builder: (context, state) => const UserEventsScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/support', builder: (context, state) => const SupportChatScreen()),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(path: '/privacy', builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: '/vendor-terms', builder: (context, state) => const VendorTermsScreen()),
      GoRoute(path: '/vendor', builder: (context, state) => const VendorDashboardScreen()),
      GoRoute(path: '/vendors', builder: (context, state) => const VendorListScreen()),
      GoRoute(
        path: '/vendors/details', 
        builder: (context, state) => VendorDetailsScreen(vendor: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(path: '/vendor/waiting', builder: (context, state) => const VendorWaitingApprovalScreen()),
      GoRoute(path: '/vendor/profile', builder: (context, state) => const VendorProfileScreen()),
      GoRoute(path: '/vendor/edit-profile', builder: (context, state) => const EditVendorProfileScreen()),
      GoRoute(path: '/vendor/payment-received', builder: (context, state) => const PaymentReceivedScreen()),
      GoRoute(path: '/vendor/payment-request', builder: (context, state) => const VendorCreatePaymentRequestScreen()),
      GoRoute(
        path: '/vendor/qr',
        builder: (context, state) {
          final requestId = state.extra as String?;
          if (requestId == null) {
            // Reached without a request id (e.g. deep link) — send back to create one.
            return const _RedirectToPaymentRequest();
          }
          return VendorQrPaymentScreen(requestId: requestId);
        },
      ),
      GoRoute(path: '/vendor/offers', builder: (context, state) => const VendorOffersScreen()),
      GoRoute(path: '/vendor/transactions', builder: (context, state) => const VendorTransactionHistoryScreen()),
      GoRoute(path: '/vendor/sales-report', builder: (context, state) => const VendorSalesReportScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/vendors', builder: (context, state) => const AdminManageVendorsScreen()),
      GoRoute(path: '/admin/vendor-details', builder: (context, state) => const AdminVendorDetailsScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
      GoRoute(path: '/admin/transactions', builder: (context, state) => const AdminTransactionsScreen()),
      GoRoute(path: '/admin/transaction-details', builder: (context, state) => const AdminTransactionDetailsScreen()),
      GoRoute(path: '/admin/offers', builder: (context, state) => const AdminOffersScreen()),
      GoRoute(path: '/admin/events', builder: (context, state) => const AdminEventsScreen()),
      GoRoute(path: '/admin/settings', builder: (context, state) => const AdminSettingsScreen()),
      GoRoute(path: '/admin/reports', builder: (context, state) => const AdminReportsScreen()),
      GoRoute(path: '/admin/issues', builder: (context, state) => const ReportedIssuesScreen()),
      GoRoute(path: '/admin/support', builder: (context, state) => const AdminSupportChatsScreen()),
      GoRoute(
        path: '/admin/support/chat',
        builder: (context, state) => AdminSupportChatDetailScreen(chatId: state.extra as String),
      ),
    ],
  );
}

class _RedirectToPaymentRequest extends StatelessWidget {
  const _RedirectToPaymentRequest();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/vendor/payment-request');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
  String? _accountStatus;
  String? _vendorStatus;
  bool _isEmailVerified = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  String? get role => _role;
  String? get accountStatus => _accountStatus;
  String? get vendorStatus => _vendorStatus;
  bool get isEmailVerified => _isEmailVerified;

  _AuthStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _userDocSub?.cancel();
      if (user == null) {
        _role = null;
        _accountStatus = null;
        _vendorStatus = null;
        _isEmailVerified = false;
        notifyListeners();
        return;
      }
      _userDocSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        final data = doc.data();
        _role = (data?['role'] as String?)?.trim() ?? UserRole.normalUser;
        _accountStatus = (data?['accountStatus'] as String?)?.trim();
        _vendorStatus = (data?['vendorStatus'] as String?)?.trim();
        // Firestore's isEmailVerified is the field the rest of the app treats
        // as authoritative (it's what login_screen checks and what
        // email_verification_screen writes). FirebaseAuth's own
        // currentUser.emailVerified only updates after an explicit reload(),
        // so it can lag behind — OR-ing the two avoids the router gate
        // blocking every navigation for an account that's actually verified.
        _isEmailVerified = (data?['isEmailVerified'] as bool? ?? false) ||
            FirebaseAuth.instance.currentUser?.emailVerified == true;
        notifyListeners();
      });
    });
  }
}