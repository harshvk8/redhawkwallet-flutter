import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';
import 'package:redhawkwallet_flutter/features/student/models/demo_transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final DemoTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: transaction.vendor,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(radius: 36, child: Text(transaction.vendor[0])),
                  const SizedBox(height: 16),
                  Text(
                    transaction.amount,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(transaction.status),
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: transaction.statusColor,
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('Vendor'),
                  subtitle: Text(transaction.vendor),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date'),
                  subtitle: Text(transaction.date),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Category'),
                  subtitle: Text(transaction.category),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: const Text('Location'),
                  subtitle: Text(transaction.location),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.credit_card_outlined),
                  title: const Text('Payment method'),
                  subtitle: Text(transaction.paymentMethod),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(transaction.note),
            ),
          ),
        ],
      ),
    );
  }
}
