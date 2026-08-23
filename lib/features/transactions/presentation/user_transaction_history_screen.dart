import 'package:flutter/material.dart';

class UserTransactionHistoryScreen extends StatefulWidget {
  const UserTransactionHistoryScreen({super.key});

  @override
  State<UserTransactionHistoryScreen> createState() => _UserTransactionHistoryScreenState();
}

class _UserTransactionHistoryScreenState extends State<UserTransactionHistoryScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Completed', 'Pending', 'Failed'];

  final List<Map<String, dynamic>> transactions = [
    {'vendor': "Sam's Cafe", 'amount': '-\$7.50', 'date': 'May 27, 2026', 'status': 'Completed', 'type': 'Red Hawk Dollars', 'icon': Icons.local_cafe},
    {'vendor': 'Campus Store', 'amount': '-\$12.99', 'date': 'May 26, 2026', 'status': 'Completed', 'type': 'Flex Dollars', 'icon': Icons.shopping_bag},
    {'vendor': 'Food Truck', 'amount': '-\$5.00', 'date': 'May 25, 2026', 'status': 'Pending', 'type': 'Red Hawk Dollars', 'icon': Icons.local_dining},
    {'vendor': 'Added Funds', 'amount': '+\$50.00', 'date': 'May 24, 2026', 'status': 'Completed', 'type': 'Top Up', 'icon': Icons.add_circle_outline},
    {'vendor': 'Hawks Pizza', 'amount': '-\$8.75', 'date': 'May 23, 2026', 'status': 'Failed', 'type': 'Red Hawk Dollars', 'icon': Icons.local_pizza},
  ];

  Color _statusColor(String status) {
    if (status == 'Completed') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.red;
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedFilter == 'All') return transactions;
    return transactions.where((t) => t['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
                      ),
                      child: Text(filter, style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = filteredTransactions[index];
                  final isDebit = (tx['amount'] as String).startsWith('-');
                  final statusColor = _statusColor(tx['status']);
                  return Container(
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
                            color: isDebit ? cs.primary.withValues(alpha: 0.1) : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(tx['icon'] as IconData, color: isDebit ? cs.primary : Colors.green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['vendor'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                              Text(tx['type'] as String, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                              Text(tx['date'] as String, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(tx['amount'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDebit ? cs.onSurface : Colors.green)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
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
