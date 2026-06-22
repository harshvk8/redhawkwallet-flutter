import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  final List<Map<String, String>> recentActivity = const [
    {'action': 'New vendor registered', 'detail': 'Hawks Pizza', 'time': '5 min ago'},
    {'action': 'Vendor approved', 'detail': 'Campus Bookstore', 'time': '1 hr ago'},
    {'action': 'New user joined', 'detail': 'student@montclair.edu', 'time': '2 hr ago'},
    {'action': 'Transaction completed', 'detail': '\$12.50 at Red Hawk Cafe', 'time': '3 hr ago'},
    {'action': 'Offer created', 'detail': '10% Student Discount', 'time': '5 hr ago'},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Red Hawk Wallet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Admin Control Panel', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _headerStat('0', 'Total Users'),
                      _headerStat('0', 'Vendors'),
                      _headerStat('0', 'Transactions'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statCard('Pending', '0', Icons.pending_actions, Colors.orange),
                const SizedBox(width: 10),
                _statCard('Suspended', '0', Icons.block, Colors.red),
                const SizedBox(width: 10),
                _statCard('Verified', '0', Icons.verified_user, Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Admin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _actionButton(context, Icons.manage_accounts, 'Manage Vendors', '/admin/vendors'),
            const SizedBox(height: 8),
            _actionButton(context, Icons.bar_chart, 'View All Transactions', '/admin/transactions'),
            const SizedBox(height: 8),
            _actionButton(context, Icons.local_offer, 'Manage Offers', '/admin/offers'),
            const SizedBox(height: 8),
            _actionButton(context, Icons.event, 'Manage Events', '/admin/events'),
            const SizedBox(height: 8),
            _actionButton(context, Icons.people, 'Manage Users', '/admin/users'),
            const SizedBox(height: 8),
            _actionButton(context, Icons.settings, 'Admin Settings', '/admin/settings'),
            const SizedBox(height: 20),
            const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...recentActivity.map((activity) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: cs.primary),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity['action']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(activity['detail']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Text(activity['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  static Widget _headerStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, String? route) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (route != null) {
            context.push(route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label coming in MVP')),
            );
          }
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
