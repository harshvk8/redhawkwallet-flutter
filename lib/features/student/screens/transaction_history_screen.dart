import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Paid', 'Pending', 'Failed'];

  final List<Map<String, dynamic>> transactions = [
    {'name': 'Campus Coffee House', 'date': 'May 27, 2026', 'time': '9:45 AM', 'amount': '-\$5.50', 'isDebit': true, 'status': 'Paid', 'icon': Icons.local_cafe},
    {'name': 'Added Funds', 'date': 'May 26, 2026', 'time': '2:30 PM', 'amount': '+\$25.00', 'isDebit': false, 'status': 'Paid', 'icon': Icons.add_circle_outline},
    {'name': 'Student Bookstore', 'date': 'May 25, 2026', 'time': '11:20 AM', 'amount': '-\$42.99', 'isDebit': true, 'status': 'Paid', 'icon': Icons.menu_book},
    {'name': 'Hawks Pizza', 'date': 'May 24, 2026', 'time': '1:00 PM', 'amount': '-\$8.75', 'isDebit': true, 'status': 'Pending', 'icon': Icons.local_pizza},
    {'name': 'Campus Prints', 'date': 'May 23, 2026', 'time': '3:15 PM', 'amount': '-\$3.00', 'isDebit': true, 'status': 'Failed', 'icon': Icons.print},
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
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
                        color: selected ? const Color(0xFF8B1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? const Color(0xFF8B1A2E) : Colors.grey.shade200),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
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
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: tx['isDebit'] as bool ? const Color(0xFFFFF0F0) : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(tx['icon'] as IconData, color: tx['isDebit'] as bool ? const Color(0xFF8B1A2E) : Colors.green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('${tx['date']} at ${tx['time']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(tx['amount'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tx['isDebit'] as bool ? Colors.black : Colors.green)),
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