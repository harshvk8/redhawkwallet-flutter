import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  final List<Map<String, dynamic>> recentTransactions = const [
    {
      'name': 'Campus Coffee House',
      'date': 'May 27, 2026 • 9:45 AM',
      'amount': '-\$5.50',
      'isDebit': true,
      'icon': Icons.local_cafe,
    },
    {
      'name': 'Added Funds',
      'date': 'May 26, 2026 • 2:30 PM',
      'amount': '+\$25.00',
      'isDebit': false,
      'icon': Icons.add_circle_outline,
    },
    {
      'name': 'Student Bookstore',
      'date': 'May 25, 2026 • 11:20 AM',
      'amount': '-\$42.99',
      'isDebit': true,
      'icon': Icons.menu_book,
    },
  ];

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
                    _buildWalletCard(context, cs),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, cs),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(context, cs),
                    const SizedBox(height: 16),
                    _buildDemoNote(cs),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context, cs),
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
              Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('Student Name', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Demo Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('USD', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/wallet'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme cs) {
    final actions = [
      {'icon': Icons.qr_code, 'label': 'QR ID', 'route': '/qr-id'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan', 'route': '/qr-scanner'},
      {'icon': Icons.local_offer, 'label': 'Offers', 'route': '/offers'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom quick actions coming soon')),
                );
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () => context.push(action['route'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(action['icon'] as IconData, color: cs.primary, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(action['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
            TextButton(
              onPressed: () => context.push('/transactions'),
              child: Text('View All', style: TextStyle(color: cs.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentTransactions.map((tx) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tx['isDebit'] as bool ? cs.primary.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tx['icon'] as IconData, color: tx['isDebit'] as bool ? cs.primary : Colors.green, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                    const SizedBox(height: 2),
                    Text(tx['date'] as String, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(tx['amount'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: tx['isDebit'] as bool ? cs.onSurface : Colors.green)),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDemoNote(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'This is a demo wallet. Start using Red Hawk Wallet to see your real transactions here!',
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home, 'Home', '/home', true, cs),
          _navItem(context, Icons.account_balance_wallet, 'Wallet', '/wallet', false, cs),
          _navItemQR(context, cs),
          _navItem(context, Icons.local_offer, 'Offers', '/offers', false, cs),
          _navItem(context, Icons.person, 'Account', '/profile', false, cs),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, String route, bool isActive, ColorScheme cs) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? cs.primary : cs.onSurfaceVariant, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: isActive ? cs.primary : cs.onSurfaceVariant, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _navItemQR(BuildContext context, ColorScheme cs) {
    return GestureDetector(
      onTap: () => context.push('/qr-id'),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: const Icon(Icons.qr_code, color: Colors.white, size: 26),
      ),
    );
  }
}
