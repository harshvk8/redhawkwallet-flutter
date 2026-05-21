import 'package:flutter/material.dart';

class AdminManageVendorsScreen extends StatelessWidget {
  const AdminManageVendorsScreen({super.key});

  final List<Map<String, String>> sampleVendors = const [
    {'name': 'Red Hawk Cafe', 'status': 'Active'},
    {'name': 'Campus Bookstore', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Vendors')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: sampleVendors.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.store),
                title: Text(sampleVendors[index]['name']!),
                subtitle: Text(sampleVendors[index]['status']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Approve')),
                    TextButton(onPressed: () {}, child: const Text('Suspend')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}