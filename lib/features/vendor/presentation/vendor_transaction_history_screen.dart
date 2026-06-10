import 'package:flutter/material.dart';

class VendorTransactionHistoryScreen extends StatefulWidget {
  const VendorTransactionHistoryScreen({super.key});

  @override
  State<VendorTransactionHistoryScreen> createState() => _VendorTransactionHistoryScreenState();
}

class _VendorTransactionHistoryScreenState extends State<VendorTransactionHistoryScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Paid', 'Pending', 'Failed'];

  final List<Map<String, dynamic>> transactions = [
    {
      'name': 'Alex Johnson',
      'amount': '\$12.50',
      'date': 'May 21, 2026',
      'time': '3:45 PM',
      'status': 'Paid',
      'note': 'Coffee order',
      'points': '12',
    },
    {
      'name': 'Sara Lee',
      'amount': '\$8.00',
      'date': 'May 21, 2026',
      'time': '2:30 PM',
      'status': 'Paid',
      'note': 'Sandwich',
      'points': '8',
    },
    {
      'name': 'Mike Chen',
      'amount': '\$22.00',
      'date': 'May 21, 2026',
      'time': '1:15 PM',
      'status': 'Pending',
      'note': 'Lunch combo',
      'points': '0',
    },
    {
      'name': 'Priya Patel',
      'amount': '\$5.00',
      'date': 'May 20, 2026',
      'time': '4:00 PM',
      'status': 'Failed',
      'note': 'Snack',
      'points': '0',
    },
    {
      'name': 'James Wu',
      'amount': '\$18.75',
      'date': 'May 20, 2026',
      'time': '12:00 PM',
      'status': 'Paid',
      'note': 'Pizza slice + drink',
      'points': '18',
    },
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
    final totalSales = transactions
        .where((t) => t['status'] == 'Paid')
        .fold(0.0, (sum, t) => sum + double.parse(t['amount'].replaceAll('\$', '')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _summaryCard('Total Sales', '\$${totalSales.toStringAsFixed(2)}', Icons.attach_money),
                const SizedBox(width: 10),
                _summaryCard('Transactions', '${transactions.length}', Icons.receipt_long),
                const SizedBox(width: 10),
                _summaryCard('Pending', '${transactions.where((t) => t['status'] == 'Pending').length}', Icons.pending_actions),
              ],
            ),
            const SizedBox(height: 12),
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
                        color: selected ? const Color(0xFFC8102E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = filteredTransactions[index];
                  final statusColor = _statusColor(tx['status']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
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
                                  backgroundColor: const Color(0xFFFFF0F0),
                                  child: Text(
                                    tx['name'][0],
                                    style: const TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(tx['note'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(tx['amount'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(tx['status'], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${tx['date']} at ${tx['time']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC8102E), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFC8102E), size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}