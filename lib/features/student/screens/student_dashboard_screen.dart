import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Student Dashboard',
      showBackButton: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _HeroCard(),
          const SizedBox(height: 24),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _NavButton(
                label: 'Profile',
                icon: Icons.person_outline,
                onTap: () => context.push('/profile'),
              ),
              _NavButton(
                label: 'Verify',
                icon: Icons.verified_user_outlined,
                onTap: () => context.push('/verify'),
              ),
              _NavButton(
                label: 'My QR',
                icon: Icons.qr_code_2,
                onTap: () => context.push('/qr-id'),
              ),
              _NavButton(
                label: 'Scan',
                icon: Icons.qr_code_scanner,
                onTap: () => context.push('/qr-scanner'),
              ),
              _NavButton(
                label: 'Transactions',
                icon: Icons.receipt_long_outlined,
                onTap: () => context.push('/transactions'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.north_west),
                  title: Text('Bookstore purchase'),
                  subtitle: Text('Today · \$8.50 · Approved'),
                  trailing: Text('-\$8.50'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.south_east),
                  title: Text('Dining hall refund'),
                  subtitle: Text('Yesterday · \$3.25 · Refunded'),
                  trailing: Text('+\$3.25'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Jordan Hawke',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text('jordan.hawke@redhawks.edu'),
            SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(label: 'Wallet balance', value: '\$42.18'),
                _StatChip(label: 'Status', value: 'Verified student'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.circle, size: 12),
      label: Text('$label: $value'),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

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
