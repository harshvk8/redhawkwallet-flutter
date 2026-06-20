import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(cs),
                    const SizedBox(height: 20),
                    Text('Quick Access', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
                    const SizedBox(height: 12),
                    _buildQuickAccessGrid(context, cs),
                    const SizedBox(height: 20),
                    _buildRecentTransaction(context, cs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: cs.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('Student Name', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Demo', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text('250', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Next reward at 500', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, ColorScheme cs) {
    final items = [
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet', 'color': cs.primary},
      {'icon': Icons.local_offer, 'label': 'Offers', 'color': Colors.orange},
      {'icon': Icons.event, 'label': 'Events', 'color': Colors.blue},
      {'icon': Icons.qr_code, 'label': 'QR ID', 'color': Colors.purple},
      {'icon': Icons.history, 'label': 'Transactions', 'color': Colors.teal},
      {'icon': Icons.person, 'label': 'Profile', 'color': Colors.green},
      {'icon': Icons.star, 'label': 'Rewards', 'color': Colors.amber},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.grey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(item['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransaction(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transaction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
              TextButton(onPressed: () => context.push('/transactions'), child: Text('View All', style: TextStyle(color: cs.primary))),
            ],
          ),
          const Divider(),
          _txRow('Campus Coffee House', '-\$5.50', 'May 27', cs),
          _txRow('Added Funds', '+\$25.00', 'May 26', cs),
          _txRow('Student Bookstore', '-\$42.99', 'May 25', cs),
        ],
      ),
    );
  }

  Widget _txRow(String name, String amount, String date, ColorScheme cs) {
    final isDebit = amount.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 13, color: cs.onSurface)),
          Row(
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDebit ? cs.onSurface : Colors.green)),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
