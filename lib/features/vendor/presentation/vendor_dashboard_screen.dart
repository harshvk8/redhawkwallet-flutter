import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_notifier.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, String>> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        recentTransactions = [
          {'name': 'Alex Johnson', 'amount': '\$12.50', 'time': '2 min ago', 'status': 'Paid'},
          {'name': 'Sara Lee', 'amount': '\$8.00', 'time': '15 min ago', 'status': 'Paid'},
          {'name': 'Mike Chen', 'amount': '\$22.00', 'time': '1 hr ago', 'status': 'Paid'},
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendor Dashboard'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => context.push('/notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [colorScheme.primary, const Color(0xFFC8102E)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Red Hawk Cafe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Active Vendor', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        SizedBox(height: 16),
                        Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        Text('Total Sales Today (Demo)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statCard(context, 'Orders', '0', Icons.receipt_long),
                      const SizedBox(width: 10),
                      _statCard(context, 'Offers', '3', Icons.local_offer),
                      const SizedBox(width: 10),
                      _statCard(context, 'Points Given', '0', Icons.stars),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _quickAction(context, Icons.qr_code, 'Request Payment', '/vendor/payment-request')),
                      const SizedBox(width: 10),
                      Expanded(child: _quickAction(context, Icons.local_offer, 'My Offers', '/vendor/offers')),
                      const SizedBox(width: 10),
                      Expanded(child: _quickAction(context, Icons.history, 'History', '/vendor/transactions')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildTransactionsSection(context),
                ],
              ),
            ),
            _buildSettingsTab(context),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: TabBar(
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_outlined)),
                Tab(text: 'Settings', icon: Icon(Icons.settings_outlined)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                Text('Appearance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dark Mode', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Switch the vendor dashboard between light and dark themes.', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: ThemeNotifier.instance,
                      builder: (context, mode, _) {
                        return Switch.adaptive(
                          value: mode == ThemeMode.dark,
                          onChanged: (value) {
                            ThemeNotifier.instance.value = value ? ThemeMode.dark : ThemeMode.light;
                          },
                          activeThumbColor: colorScheme.primary,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: Color(0xFFC8102E)),
        ),
      );
    }
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text('Something went wrong.', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
            ),
          ],
        ),
      );
    }
    if (recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text('No transactions yet', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Your transactions will appear here.', style: TextStyle(fontSize: 13)),
          ],
        ),
      );
    }
    return Column(
      children: recentTransactions.map((tx) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(tx['name']![0], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['name']!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(tx['time']!, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(tx['amount']!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(tx['status']!, style: TextStyle(color: Colors.green.shade700, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, String route) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.onPrimary, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: colorScheme.onPrimary, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
