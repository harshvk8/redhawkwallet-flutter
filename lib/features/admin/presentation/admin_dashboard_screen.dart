import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  final List<Map<String, String>> recentActivity = const [
    {'action': 'New vendor registered', 'detail': 'Hawks Pizza', 'time': '5 min ago'},
    {'action': 'Vendor approved', 'detail': 'Campus Bookstore', 'time': '1 hr ago'},
    {'action': 'New user joined', 'detail': 'student@montclair.edu', 'time': '2 hr ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statCard('Users', '0', Icons.people),
                const SizedBox(width: 10),
                _statCard('Vendors', '0', Icons.store),
                const SizedBox(width: 10),
                _statCard('Pending', '0', Icons.pending_actions),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Admin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _actionButton(Icons.manage_accounts, 'Manage Vendors', onPressed: () => context.go('/admin/manage-vendors')),
            const SizedBox(height: 8),
            _actionButton(Icons.bar_chart, 'View All Transactions'),
            const SizedBox(height: 8),
            _actionButton(Icons.local_offer, 'Manage Offers'),
            const SizedBox(height: 8),
            _actionButton(Icons.school, 'Manage Student Verifications'),
            const SizedBox(height: 20),
            const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...recentActivity.map((activity) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity['action']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(activity['detail']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  Text(activity['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC8102E), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFC8102E), size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8102E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}