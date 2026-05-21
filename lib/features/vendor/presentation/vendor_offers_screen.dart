import 'package:flutter/material.dart';

class VendorOffersScreen extends StatelessWidget {
  const VendorOffersScreen({super.key});

  final List<Map<String, String>> sampleOffers = const [
    {'title': '10% Student Discount', 'description': 'Valid for verified students'},
    {'title': 'Buy 1 Get 1 Coffee', 'description': 'Every Monday'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Offers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New Offer'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sampleOffers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_offer),
                      title: Text(sampleOffers[index]['title']!),
                      subtitle: Text(sampleOffers[index]['description']!),
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