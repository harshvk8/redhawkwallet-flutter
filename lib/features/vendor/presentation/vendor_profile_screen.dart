import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs, user),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildBusinessInfo(cs),
                    const SizedBox(height: 16),
                    _buildStatsRow(cs),
                    const SizedBox(height: 16),
                    _buildMenu(context, cs),
                    const SizedBox(height: 16),
                    _buildLogout(context, cs),
                    const SizedBox(height: 16),
                    const Text('Red Hawk Wallet v1.0.0 — Vendor Portal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs, User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      color: cs.primary,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => context.push('/vendor/profile/edit'),
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.storefront, color: Colors.white, size: 44),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, color: cs.primary, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user?.displayName ?? 'Business Name',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'business@example.com',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.storefront, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('Vendor', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Approved', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfo(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 14),
          _detailRow(Icons.category_outlined, 'Category', 'Food & Beverage', cs),
          const Divider(height: 20),
          _detailRow(Icons.location_on_outlined, 'Location', 'Campus Building A, Floor 1', cs),
          const Divider(height: 20),
          _detailRow(Icons.phone_outlined, 'Phone', '+1 (555) 000-0000', cs),
          const Divider(height: 20),
          _detailRow(Icons.schedule, 'Hours', 'Mon–Fri 8am–6pm', cs),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: cs.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(ColorScheme cs) {
    return Row(
      children: [
        _statCard('Total Sales', '\$2,840', Icons.attach_money, cs),
        const SizedBox(width: 10),
        _statCard('Transactions', '142', Icons.receipt_long, cs),
        const SizedBox(width: 10),
        _statCard('Avg Order', '\$19.99', Icons.trending_up, cs),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, ColorScheme cs) {
    final items = [
      {'icon': Icons.edit_outlined, 'label': 'Edit Profile', 'route': '/vendor/profile/edit'},
      {'icon': Icons.bar_chart, 'label': 'Sales Report', 'route': '/vendor/sales-report'},
      {'icon': Icons.local_offer_outlined, 'label': 'Manage Offers', 'route': '/vendor/offers'},
      {'icon': Icons.history, 'label': 'Transaction History', 'route': '/vendor/transactions'},
      {'icon': Icons.settings_outlined, 'label': 'Settings', 'route': '/settings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (i > 0) Divider(height: 1, color: Colors.grey.shade100),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item['icon'] as IconData, color: cs.primary, size: 20),
                ),
                title: Text(item['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: () => context.push(item['route'] as String),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogout(BuildContext context, ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) context.go('/login');
        },
        icon: Icon(Icons.logout, color: cs.primary),
        label: Text('Logout', style: TextStyle(color: cs.primary, fontSize: 15)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: cs.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
