import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../wallet/models/transaction_model.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Completed', 'Pending', 'Failed'];

  Color _statusColor(String status) {
    if (status == 'completed') return Colors.green;
    if (status == 'pending') return Colors.orange;
    return Colors.red;
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> transactions) {
    if (selectedFilter == 'All') return transactions;
    return transactions.where((t) => t.status == selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? cs.primary : Colors.grey.shade200),
                      ),
                      child: Text(filter, style: TextStyle(color: selected ? Colors.white : cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: cs.primary));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load transactions.'));
                  }
                  final transactions = _applyFilter(
                    (snapshot.data?.docs ?? []).map(TransactionModel.fromFirestore).toList(),
                  );
                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        selectedFilter == 'All' ? 'No transactions yet.' : 'No $selectedFilter transactions.',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final statusColor = _statusColor(tx.status);
                      final statusLabel = tx.status[0].toUpperCase() + tx.status.substring(1);
                      return GestureDetector(
                        onTap: () => context.push('/admin/transaction-details', extra: {
                          'id': tx.id,
                          'fromName': tx.fromName.isNotEmpty ? tx.fromName : 'Unknown',
                          'toName': tx.toName.isNotEmpty ? tx.toName : 'Unknown',
                          'amount': tx.amount,
                          'status': statusLabel,
                          'createdAt': tx.createdAt,
                          'description': tx.description,
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tx.id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(tx.fromName.isNotEmpty ? tx.fromName : 'Unknown', style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.store_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(tx.toName.isNotEmpty ? tx.toName : 'Unknown', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${tx.createdAt.month}/${tx.createdAt.day}/${tx.createdAt.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text('\$${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
