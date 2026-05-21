import 'package:flutter/material.dart';

class VendorQrPaymentScreen extends StatelessWidget {
  const VendorQrPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor QR Payment')),
      body: const Center(child: Text('Vendor QR Payment Screen')),
    );
  }
}