import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorDetailsScreen extends StatelessWidget {
  const VendorDetailsScreen({super.key, this.vendor});

  final Map<String, dynamic>? vendor;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final data = vendor ?? const {
      'name': 'Red Hawk Cafe',
      'category': 'Dining',
      'rating': 4.8,
      'distance': '0.2 mi',
      'status': 'Open now',
      'color': Color(0xFF8B1A2E),
      'hours': '7:00 AM - 9:00 PM',
      'description': 'Popular stop for coffee, sandwiches, and campus favorites.',
    };
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
=======
    final data = vendor ?? const {'name': 'Vendor', 'category': 'Other', 'uid': ''};
>>>>>>> origin/dev

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Vendor Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(data),
            const SizedBox(height: 16),
            _infoCard(context, data),
            const SizedBox(height: 16),
<<<<<<< HEAD
            _menuPreview(context),
            const SizedBox(height: 16),
=======
>>>>>>> origin/dev
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/wallet/pay-vendor', extra: data),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Continue to Pay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(data['category'] as String),
              _pill('Approved vendor'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vendor Info', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
<<<<<<< HEAD
          _row(context, Icons.place_outlined, 'Distance', data['distance'] as String),
          _row(context, Icons.schedule_outlined, 'Hours', data['hours'] as String? ?? '7:00 AM - 9:00 PM'),
          _row(context, Icons.storefront_outlined, 'Category', data['category'] as String),
          _row(context, Icons.verified_outlined, 'Status', data['status'] as String),
=======
          _row(Icons.storefront_outlined, 'Category', data['category'] as String),
          _row(Icons.verified_outlined, 'Status', 'Approved'),
          const SizedBox(height: 4),
          const Text('Menu and hours are managed by the vendor and coming soon.', style: TextStyle(color: Colors.grey, fontSize: 12)),
>>>>>>> origin/dev
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _menuPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = [
      ('Iced Coffee', '\$ 3.50'),
      ('Chicken Wrap', '\$ 6.75'),
      ('Student Combo', '\$ 8.25'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Items', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.$1, style: theme.textTheme.bodyMedium),
                  Text(item.$2, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
=======
}
>>>>>>> origin/dev
