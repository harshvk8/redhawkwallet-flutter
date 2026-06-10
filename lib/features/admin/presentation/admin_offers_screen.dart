import 'package:flutter/material.dart';

class AdminOffersScreen extends StatelessWidget {
  const AdminOffersScreen({super.key});

  final List<Map<String, dynamic>> offers = const [
    {'title': '10% Student Discount', 'vendor': 'Red Hawk Cafe', 'discount': '10%', 'expiry': 'Jun 30, 2026', 'status': 'Active'},
    {'title': 'Buy 1 Get 1 Coffee', 'vendor': 'Red Hawk Cafe', 'discount': 'BOGO', 'expiry': 'Jun 15, 2026', 'status': 'Active'},
    {'title': 'Free Delivery', 'vendor': 'Hawks Pizza', 'discount': 'FREE', 'expiry': 'May 31, 2026', 'status': 'Pending'},
    {'title': '15% Off Books', 'vendor': 'Campus Bookstore', 'discount': '15%', 'expiry': 'Jun 1, 2026', 'status': 'Disabled'},
  ];

  Color _statusColor(String status) {
    if (status == 'Active') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Manage Offers'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            final statusColor = _statusColor(offer['status']);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(offer['discount'], style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Text(offer['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(offer['status'], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(offer['vendor'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Expires: ${offer['expiry']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Approve', style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Disable', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}