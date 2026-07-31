import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(colorScheme),
                    const SizedBox(height: 20),
                    Text('Quick Access', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildQuickAccessGrid(context),
                    const SizedBox(height: 20),
                    _buildRecentTransaction(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, const Color(0xFFC8102E)]),
      ),
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

  Widget _buildSummaryRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary,
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

  Widget _buildQuickAccessGrid(BuildContext context) {
    final items = [
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet', 'color': const Color(0xFF8B1A2E), 'route': '/wallet'},
      {'icon': Icons.local_offer, 'label': 'Offers', 'color': Colors.orange, 'route': '/offers'},
      {'icon': Icons.event, 'label': 'Events', 'color': Colors.blue, 'route': null},
      {'icon': Icons.qr_code, 'label': 'QR ID', 'color': Colors.purple, 'route': '/qr-id'},
      {'icon': Icons.history, 'label': 'Transactions', 'color': Colors.teal, 'route': '/transactions'},
      {'icon': Icons.person, 'label': 'Profile', 'color': Colors.green, 'route': '/profile'},
      {'icon': Icons.star, 'label': 'Rewards', 'color': Colors.amber, 'route': '/rewards'},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.grey, 'route': '/settings'},
    ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final route = item['route'] as String?;
              if (route == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Events are demo-only in this build.')),
                );
                return;
              }
              context.push(route);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransaction(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transaction', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              TextButton(onPressed: () => context.push('/transactions'), child: const Text('View All')),
            ],
          ),
          const Divider(),
          _txRow(context, 'Campus Coffee House', '-\$5.50', 'May 27'),
          _txRow(context, 'Added Funds', '+\$25.00', 'May 26'),
          _txRow(context, 'Student Bookstore', '-\$42.99', 'May 25'),
        ],
      ),
    );
  }

  Widget _txRow(BuildContext context, String name, String amount, String date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDebit = amount.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: theme.textTheme.bodyMedium),
          Row(
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDebit ? colorScheme.onSurface : Colors.green)),
              const SizedBox(width: 8),
              Text(date, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}