import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_states.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Completed', 'Pending', 'Failed'];
  bool _isLoading = true;
  bool _hasError = false;

  final List<Map<String, dynamic>> transactions = [
    {'id': 'TXN-001', 'user': 'Alex Johnson', 'vendor': 'Red Hawk Cafe', 'amount': '\$12.50', 'status': 'Completed', 'date': 'May 27, 2026'},
    {'id': 'TXN-002', 'user': 'Sara Lee', 'vendor': 'Campus Bookstore', 'amount': '\$42.99', 'status': 'Completed', 'date': 'May 27, 2026'},
    {'id': 'TXN-003', 'user': 'Mike Chen', 'vendor': 'Hawks Pizza', 'amount': '\$8.75', 'status': 'Pending', 'date': 'May 26, 2026'},
    {'id': 'TXN-004', 'user': 'Priya Patel', 'vendor': 'Campus Prints', 'amount': '\$3.00', 'status': 'Failed', 'date': 'May 26, 2026'},
    {'id': 'TXN-005', 'user': 'James Wu', 'vendor': 'Red Hawk Cafe', 'amount': '\$15.25', 'status': 'Completed', 'date': 'May 25, 2026'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

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
    final filtered = filteredTransactions;

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions'), elevation: 0),
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
                        border: Border.all(color: selected ? cs.primary : Colors.grey.shade200),
                      ),
                      child: Text(filter, style: TextStyle(color: selected ? Colors.white : cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const AppLoadingState(message: 'Loading transactions…')
                  : _hasError
                      ? AppErrorState(onRetry: _load)
                      : filtered.isEmpty
                          ? AppEmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'No $selectedFilter transactions',
                              subtitle: 'There are no transactions matching this filter.',
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final tx = filtered[index];
                                final statusColor = _statusColor(tx['status'] as String);
                                return GestureDetector(
                                  onTap: () => context.push('/admin/transaction-details', extra: tx),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade100),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(tx['id'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                              child: Text(tx['status'] as String, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(tx['user'] as String, style: const TextStyle(fontSize: 13)),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.store_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(tx['vendor'] as String, style: const TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(tx['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            Row(
                                              children: [
                                                Text(tx['amount'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
