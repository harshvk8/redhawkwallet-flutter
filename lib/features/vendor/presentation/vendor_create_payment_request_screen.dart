import 'package:flutter/material.dart';

class VendorCreatePaymentRequestScreen extends StatelessWidget {
  const VendorCreatePaymentRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Payment Request')),
      body: const Center(child: Text('Create Payment Request Screen')),
    );
  }
}