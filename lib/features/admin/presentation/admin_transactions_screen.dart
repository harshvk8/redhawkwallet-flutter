import 'package:flutter/material.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Completed', 'Pending', 'Failed'];

  final List<Map<String, dynamic>> transactions = [
    {'id': 'TXN-001', 'user': 'Alex Johnson', 'vendor': 'Red Hawk Cafe', 'amount': '\$12.50', 'status': 'Completed', 'date': 'May 27, 2026'},
    {'id': 'TXN-002', 'user': 'Sara Lee', 'vendor': 'Campus Bookstore', 'amount': '\$42.99', 'status': 'Completed', 'date': 'May 27, 2026'},
    {'id': 'TXN-003', 'user': 'Mike Chen', 'vendor': 'Hawks Pizza', 'amount': '\$8.75', 'status': 'Pending', 'date': 'May 26, 2026'},
    {'id': 'TXN-004', 'user': 'Priya Patel', 'vendor': 'Campus Prints', 'amount': '\$3.00', 'status': 'Failed', 'date': 'May 26, 2026'},
    {'id': 'TXN-005', 'user': 'James Wu', 'vendor': 'Red Hawk Cafe', 'amount': '\$15.25', 'status': 'Completed', 'date': 'May 25, 2026'},
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('All Transactions'),
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
                        color: selected ? const Color(0xFF8B1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? const Color(0xFF8B1A2E) : Colors.grey.shade200),
                      ),
                      child: Text(filter, style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
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
                  final statusColor = _statusColor(tx['status']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tx['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8B1A2E))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(tx['status'], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(tx['user'], style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),
                            const Icon(Icons.store_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(tx['vendor'], style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tx['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(tx['amount'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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