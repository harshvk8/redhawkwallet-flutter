import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_state_view.dart';
import 'package:redhawkwallet_flutter/features/student/models/demo_transaction.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  static const List<DemoTransaction> transactions = [
    DemoTransaction(
      vendor: '1908',
      amount: '-\$11.40',
      date: 'Today · 12:40 PM',
      status: 'Approved',
      statusColor: Colors.green,
      category: 'Dining',
      location: 'Campus Center',
      paymentMethod: 'RedHawk Wallet',
      note: 'Lunch purchase at the campus convenience stop.',
    ),
    DemoTransaction(
      vendor: 'Freeman Dining Hall',
      amount: '-\$8.25',
      date: 'Today · 9:15 AM',
      status: 'Pending',
      statusColor: Colors.orange,
      category: 'Dining',
      location: 'Freeman Dining Hall',
      paymentMethod: 'RedHawk Wallet',
      note: 'Breakfast order is still processing through campus payments.',
    ),
    DemoTransaction(
      vendor: 'Freshens',
      amount: '-\$6.80',
      date: 'Yesterday · 2:10 PM',
      status: 'Approved',
      statusColor: Colors.green,
      category: 'Dining',
      location: 'Student Union',
      paymentMethod: 'Dining plan',
      note: 'Smoothie and snack purchase after class.',
    ),
    DemoTransaction(
      vendor: 'Java Love',
      amount: '-\$4.75',
      date: '2 days ago · 8:05 AM',
      status: 'Approved',
      statusColor: Colors.green,
      category: 'Coffee',
      location: 'Library Lobby',
      paymentMethod: 'RedHawk Wallet',
      note: 'Morning coffee before a study session.',
    ),
    DemoTransaction(
      vendor: 'Sam’s Place',
      amount: '-\$13.60',
      date: '3 days ago · 6:30 PM',
      status: 'Declined',
      statusColor: Colors.red,
      category: 'Retail',
      location: 'Campus Commons',
      paymentMethod: 'RedHawk Wallet',
      note: 'Purchase was declined after the wallet balance check.',
    ),
  ];

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  DemoScreenStatus _status = DemoScreenStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _status = DemoScreenStatus.loading;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    setState(() {
      _status = TransactionHistoryScreen.transactions.isEmpty
          ? DemoScreenStatus.empty
          : DemoScreenStatus.ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'Transaction History',
      body: DemoScreenStateView(
        status: _status,
        onRetry: _loadTransactions,
        emptyIcon: Icons.receipt_long_outlined,
        emptyTitle: 'No transactions yet',
        emptyMessage: 'Your transaction history will appear here.',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            _HistorySummary(),
            const SizedBox(height: 20),
            Text(
              'Recent transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const _TransactionList(),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (
            var index = 0;
            index < TransactionHistoryScreen.transactions.length;
            index++
          ) ...[
            _TransactionTile(
              entry: TransactionHistoryScreen.transactions[index],
            ),
            if (index < TransactionHistoryScreen.transactions.length - 1)
              const Divider(height: 0),
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final DemoTransaction entry;

  const _TransactionTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final avatarLabel = entry.vendor.isNotEmpty ? entry.vendor[0] : '?';

    return InkWell(
      onTap: () => context.push('/transaction-detail', extra: entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Text(avatarLabel)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.vendor,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(entry.date),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.amount,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(entry.status),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  backgroundColor: entry.statusColor,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
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
