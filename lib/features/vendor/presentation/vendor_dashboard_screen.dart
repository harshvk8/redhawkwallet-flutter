import 'package:flutter/material.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  final List<Map<String, String>> recentTransactions = const [
    {'name': 'Alex Johnson', 'amount': '\$12.50', 'time': '2 min ago', 'status': 'Paid'},
    {'name': 'Sara Lee', 'amount': '\$8.00', 'time': '15 min ago', 'status': 'Paid'},
    {'name': 'Mike Chen', 'amount': '\$22.00', 'time': '1 hr ago', 'status': 'Paid'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC8102E),
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
                _statCard('Orders', '0', Icons.receipt_long),
                const SizedBox(width: 10),
                _statCard('Offers', '3', Icons.local_offer),
                const SizedBox(width: 10),
                _statCard('Points Given', '0', Icons.stars),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _quickAction(Icons.qr_code, 'Request Payment')),
                const SizedBox(width: 10),
                Expanded(child: _quickAction(Icons.local_offer, 'My Offers')),
                const SizedBox(width: 10),
                Expanded(child: _quickAction(Icons.history, 'History')),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...recentTransactions.map((tx) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFFFF0F0),
                        child: Text(tx['name']![0], style: const TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(tx['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(tx['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tx['status']!, style: TextStyle(color: Colors.green.shade700, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
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
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC8102E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}