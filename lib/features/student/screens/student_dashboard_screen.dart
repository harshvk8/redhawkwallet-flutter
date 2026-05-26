import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/services/auth_service.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _NavButton(
                      label: 'Profile',
                      icon: Icons.person_outline,
                      onTap: () => context.go('/profile'),
                    ),
                    _NavButton(
                      label: 'Verify',
                      icon: Icons.verified_user_outlined,
                      onTap: () => context.go('/verify'),
                    ),
                    _NavButton(
                      label: 'My QR',
                      icon: Icons.qr_code_2,
                      onTap: () => context.go('/qr-id'),
                    ),
                    _NavButton(
                      label: 'Scan',
                      icon: Icons.qr_code_scanner,
                      onTap: () => context.go('/qr-scanner'),
                    ),
                    _NavButton(
                      label: 'Transactions',
                      icon: Icons.receipt_long_outlined,
                      onTap: () => context.go('/transactions'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
