import 'package:flutter/material.dart';

class AdminManageVendorsScreen extends StatelessWidget {
  const AdminManageVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Vendors')),
      body: const Center(child: Text('Manage Vendors Screen')),
    );
  }
}