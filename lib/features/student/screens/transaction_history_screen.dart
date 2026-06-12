import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Transaction History',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _HistorySummary(),
          SizedBox(height: 24),
          Text(
            'Recent transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.storefront_outlined)),
                  title: Text('Campus Cafe'),
                  subtitle: Text('Today · Latte and snack'),
                  trailing: Text('-\$8.50'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.school_outlined)),
                  title: Text('Housing office'),
                  subtitle: Text('Yesterday · Refund'),
                  trailing: Text('+\$12.00'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.local_mall_outlined)),
                  title: Text('Bookstore'),
                  subtitle: Text('2 days ago · Supplies'),
                  trailing: Text('-\$24.75'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 96),
            SizedBox(height: 16),
            Text(
              'Transaction History',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Demo entries are shown until real wallet data is connected.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
