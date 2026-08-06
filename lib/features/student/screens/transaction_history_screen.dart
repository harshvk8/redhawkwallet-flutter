import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String selectedFilter = 'All';
<<<<<<< HEAD
  final List<String> filters = ['All', 'Paid', 'Pending', 'Failed'];

  final List<Map<String, dynamic>> transactions = [
    {'name': 'Campus Coffee House', 'date': 'May 27, 2026', 'time': '9:45 AM', 'amount': '-\$5.50', 'isDebit': true, 'status': 'Paid', 'icon': Icons.local_cafe},
    {'name': 'Added Funds', 'date': 'May 26, 2026', 'time': '2:30 PM', 'amount': '+\$25.00', 'isDebit': false, 'status': 'Paid', 'icon': Icons.add_circle_outline},
    {'name': 'Student Bookstore', 'date': 'May 25, 2026', 'time': '11:20 AM', 'amount': '-\$42.99', 'isDebit': true, 'status': 'Paid', 'icon': Icons.menu_book},
    {'name': 'Hawks Pizza', 'date': 'May 24, 2026', 'time': '1:00 PM', 'amount': '-\$8.75', 'isDebit': true, 'status': 'Pending', 'icon': Icons.local_pizza},
    {'name': 'Campus Prints', 'date': 'May 23, 2026', 'time': '3:15 PM', 'amount': '-\$3.00', 'isDebit': true, 'status': 'Failed', 'icon': Icons.print},
  ];
=======
  // Pending/Failed will always be empty today — transferMoney only ever
  // writes status: "completed" (it throws before writing anything on
  // failure). Kept for when a pending/async payment path exists.
  final List<String> filters = ['All', 'Completed', 'Pending', 'Failed'];
>>>>>>> origin/dev

  Color _statusColor(String status) {
    if (status == 'Paid') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.red;
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedFilter == 'All') return transactions;
    return transactions.where((t) => t['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Transaction History'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? colorScheme.primary : colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? colorScheme.primary : colorScheme.outlineVariant),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
<<<<<<< HEAD
              child: ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = filteredTransactions[index];
                  final statusColor = _statusColor(tx['status']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
=======
              child: uid == null
                  ? const Center(child: Text('Not signed in.'))
                  : StreamBuilder<QuerySnapshot>(
                      // array-contains + orderBy on a different field needs a
                      // composite index, so we sort client-side instead of in
                      // the query — same approach used elsewhere in this app.
                      stream: FirebaseFirestore.instance
                          .collection('transactions')
                          .where('participants', arrayContains: uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: cs.primary));
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Failed to load transactions.'));
                        }
                        final all = (snapshot.data?.docs ?? []).map(TransactionModel.fromFirestore).toList()
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                        final transactions = _applyFilter(all);
                        if (transactions.isEmpty) {
                          return Center(
                            child: Text(
                              selectedFilter == 'All' ? 'No transactions yet.' : 'No $selectedFilter transactions.',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            final statusColor = _statusColor(tx.status);
                            final hour = tx.createdAt.hour % 12 == 0 ? 12 : tx.createdAt.hour % 12;
                            final period = tx.createdAt.hour >= 12 ? 'PM' : 'AM';
                            final isReceived = tx.toUid == uid;
                            final counterparty = isReceived
                                ? (tx.fromName.isNotEmpty ? tx.fromName : 'Someone')
                                : (tx.toName.isNotEmpty ? tx.toName : 'Vendor');
                            return GestureDetector(
                              onTap: () => context.push('/transaction-details', extra: {
                                'id': tx.id,
                                'fromName': tx.fromName.isNotEmpty ? tx.fromName : 'Someone',
                                'toName': tx.toName.isNotEmpty ? tx.toName : 'Vendor',
                                'amount': tx.amount,
                                'status': tx.status[0].toUpperCase() + tx.status.substring(1),
                                'createdAt': tx.createdAt,
                                'description': tx.description,
                              }),
                              child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.storefront_outlined, color: cs.primary, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(counterparty, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${tx.createdAt.month}/${tx.createdAt.day}/${tx.createdAt.year} at $hour:${_twoDigits(tx.createdAt.minute)} $period',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isReceived ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isReceived ? Colors.green : cs.onSurface),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          tx.status[0].toUpperCase() + tx.status.substring(1),
                                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              ),
                            );
                          },
                        );
                      },
>>>>>>> origin/dev
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: tx['isDebit'] as bool ? colorScheme.primary.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(tx['icon'] as IconData, color: tx['isDebit'] as bool ? colorScheme.primary : Colors.green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['name'] as String, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('${tx['date']} at ${tx['time']}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(tx['amount'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tx['isDebit'] as bool ? colorScheme.onSurface : Colors.green)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(tx['status'] as String, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}