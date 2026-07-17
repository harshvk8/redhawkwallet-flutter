import 'package:flutter/material.dart';

class VendorTransactionHistoryScreen extends StatefulWidget {
  const VendorTransactionHistoryScreen({super.key});

  @override
  State<VendorTransactionHistoryScreen> createState() =>
      _VendorTransactionHistoryScreenState();
}

class _VendorTransactionHistoryScreenState
    extends State<VendorTransactionHistoryScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Paid', 'Pending', 'Failed'];
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> transactions = [];

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
        transactions = [
          {'name': 'Alex Johnson', 'amount': '\$12.50', 'date': 'May 21, 2026', 'time': '3:45 PM', 'status': 'Paid', 'note': 'Coffee order', 'points': '12'},
          {'name': 'Sara Lee', 'amount': '\$8.00', 'date': 'May 21, 2026', 'time': '2:30 PM', 'status': 'Paid', 'note': 'Sandwich', 'points': '8'},
          {'name': 'Mike Chen', 'amount': '\$22.00', 'date': 'May 21, 2026', 'time': '1:15 PM', 'status': 'Pending', 'note': 'Lunch combo', 'points': '0'},
          {'name': 'Priya Patel', 'amount': '\$5.00', 'date': 'May 20, 2026', 'time': '4:00 PM', 'status': 'Failed', 'note': 'Snack', 'points': '0'},
          {'name': 'James Wu', 'amount': '\$18.75', 'date': 'May 20, 2026', 'time': '12:00 PM', 'status': 'Paid', 'note': 'Pizza slice + drink', 'points': '18'},
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
    final cs = Theme.of(context).colorScheme;
    final totalSales = transactions
        .where((t) => t['status'] == 'Paid')
        .fold(0.0, (sum, t) => sum + double.parse((t['amount'] as String).replaceAll('\$', '')));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isLoading && !_hasError) ...[
              Row(
                children: [
                  _summaryCard('Total Sales', '\$${totalSales.toStringAsFixed(2)}', Icons.attach_money, cs),
                  const SizedBox(width: 10),
                  _summaryCard('Transactions', '${transactions.length}', Icons.receipt_long, cs),
                  const SizedBox(width: 10),
                  _summaryCard('Pending', '${transactions.where((t) => t['status'] == 'Pending').length}', Icons.pending_actions, cs),
                ],
              ),
              const SizedBox(height: 12),
            ],
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
                        border: selected ? null : Border.all(color: cs.outlineVariant),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected ? Colors.white : cs.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(cs)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 48),
            const SizedBox(height: 12),
            const Text('Something went wrong.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Could not load transactions.', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: cs.onSurfaceVariant, size: 48),
            const SizedBox(height: 12),
            const Text('No transactions yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Transactions will appear here once customers pay.', style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final tx = filteredTransactions[index];
        final statusColor = _statusColor(tx['status'] as String);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.primary.withValues(alpha: 0.1),
                        child: Text(tx['name'][0] as String, style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(tx['note'] as String, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(tx['amount'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${tx['date']} at ${tx['time']}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  if (tx['status'] == 'Paid')
                    Row(
                      children: [
                        const Icon(Icons.stars, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('+${tx['points']} pts', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
