import 'package:flutter/material.dart';

class VendorQrPaymentScreen extends StatelessWidget {
  const VendorQrPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor QR Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 180, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('QR Code will appear here'),
            const SizedBox(height: 8),
            const Text('\$0.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate QR'),
            ),
          ],
        ),
      ),
    );
  }
}