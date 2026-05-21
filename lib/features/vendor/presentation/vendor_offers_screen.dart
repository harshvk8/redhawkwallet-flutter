import 'package:flutter/material.dart';

class VendorOffersScreen extends StatelessWidget {
  const VendorOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Offers')),
      body: const Center(child: Text('Vendor Offers Screen')),
    );
  }
}