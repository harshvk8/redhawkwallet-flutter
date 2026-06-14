import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redhawkwallet_flutter/core/data/demo_identity.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_state_view.dart';
import 'package:redhawkwallet_flutter/features/student/models/demo_transaction.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  DemoScreenStatus _status = DemoScreenStatus.loading;

  static const List<DemoTransaction> _recentTransactions = [
    DemoTransaction(
      vendor: 'Bookstore purchase',
      amount: '-\$8.50',
      date: 'Today · 10:14 AM',
      status: 'Approved',
      statusColor: Colors.green,
      category: 'Retail',
      location: 'Campus Bookstore',
      paymentMethod: 'RedHawk Wallet',
      note: 'Class supplies and notebook set purchased before lecture.',
    ),
    DemoTransaction(
      vendor: 'Dining hall refund',
      amount: '+\$3.25',
      date: 'Yesterday · 4:02 PM',
      status: 'Refunded',
      statusColor: Colors.blue,
      category: 'Dining',
      location: 'Freeman Dining Hall',
      paymentMethod: 'Dining plan',
      note: 'Meal refund credited after a duplicate swipe was resolved.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _status = DemoScreenStatus.loading;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    setState(() {
      _status = _recentTransactions.isEmpty
          ? DemoScreenStatus.empty
          : DemoScreenStatus.ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Student Dashboard',
      showBackButton: false,
      body: DemoScreenStateView(
        status: _status,
        onRetry: _loadDashboard,
        emptyIcon: Icons.timeline_outlined,
        emptyTitle: 'No recent activity yet',
        emptyMessage: 'Your dashboard will show campus wallet activity here.',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            _HeroCard(displayName: DemoIdentity.displayName),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
            Card(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < _recentTransactions.length;
                    index++
                  ) ...[
                    _ActivityTile(
                      transaction: _recentTransactions[index],
                      onTap: () => context.push(
                        '/transaction-detail',
                        extra: _recentTransactions[index],
                      ),
                    ),
                    if (index < _recentTransactions.length - 1)
                      const Divider(height: 0),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Tap a row for details',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String displayName;

  const _HeroCard({required this.displayName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('jordan.hawke@redhawks.edu'),
            const SizedBox(height: 20),
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

class _ActivityTile extends StatelessWidget {
  final DemoTransaction transaction;
  final VoidCallback onTap;

  const _ActivityTile({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        transaction.amount.startsWith('+')
            ? Icons.south_east
            : Icons.north_west,
      ),
      title: Text(transaction.vendor),
      subtitle: Text('${transaction.date} · ${transaction.status}'),
      trailing: Text(transaction.amount),
    );
  }
}
