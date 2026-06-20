import 'package:flutter/material.dart';

class UserOffersScreen extends StatelessWidget {
  const UserOffersScreen({super.key});

  final List<Map<String, dynamic>> offers = const [
    {'title': '10% off coffee', 'vendor': 'Red Hawk Cafe', 'discount': '10%', 'expiry': 'Jun 30, 2026', 'color': Color(0xFF8B1A2E)},
    {'title': 'Free topping', 'vendor': 'Hawks Pizza', 'discount': 'FREE', 'expiry': 'Jun 15, 2026', 'color': Colors.orange},
    {'title': 'Student lunch combo', 'vendor': "Sam's Cafe", 'discount': '15%', 'expiry': 'Jun 7, 2026', 'color': Colors.green},
    {'title': 'Buy 1 Get 1 Coffee', 'vendor': 'Red Hawk Cafe', 'discount': 'BOGO', 'expiry': 'Jun 1, 2026', 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Offers'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Offers', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Verify your university email to unlock more offers', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: (offer['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(offer['discount'] as String, style: TextStyle(color: offer['color'] as Color, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(offer['vendor'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('Expires ${offer['expiry']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Redeemed: ${offer['title']}!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B1A2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Redeem', style: TextStyle(fontSize: 12)),
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