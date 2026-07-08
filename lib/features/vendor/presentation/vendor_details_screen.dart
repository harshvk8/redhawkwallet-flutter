import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorDetailsScreen extends StatelessWidget {
  const VendorDetailsScreen({super.key, this.vendor});

  final Map<String, dynamic>? vendor;

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Vendor Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(data),
            const SizedBox(height: 16),
            _infoCard(data),
            const SizedBox(height: 16),
            _menuPreview(),
            const SizedBox(height: 16),
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
    final color = data['color'] as Color? ?? const Color(0xFF8B1A2E);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, const Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(data['description'] as String? ?? 'Campus vendor', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(data['category'] as String),
              _pill('${data['rating']} stars'),
              _pill(data['status'] as String),
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

  Widget _infoCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vendor Info', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row(Icons.place_outlined, 'Distance', data['distance'] as String),
          _row(Icons.schedule_outlined, 'Hours', data['hours'] as String? ?? '7:00 AM - 9:00 PM'),
          _row(Icons.storefront_outlined, 'Category', data['category'] as String),
          _row(Icons.verified_outlined, 'Status', data['status'] as String),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B1A2E), size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _menuPreview() {
    final items = [
      ('Iced Coffee', '\$ 3.50'),
      ('Chicken Wrap', '\$ 6.75'),
      ('Student Combo', '\$ 8.25'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popular Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 13)),
                  Text(item.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}