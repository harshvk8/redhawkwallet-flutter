import 'package:flutter/material.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Red Hawk Cafe'),
                subtitle: const Text('Active Vendor'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Total Sales'),
                subtitle: const Text('\$0.00 (Demo)'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code),
              label: const Text('Create Payment Request'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_offer),
              label: const Text('View Offers'),
            ),
          ],
        ),
      ),
    );
  }
}