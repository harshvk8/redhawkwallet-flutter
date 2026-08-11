import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_states.dart';

import '../../wallet/models/transaction_model.dart';

class VendorTransactionHistoryScreen extends StatefulWidget {
  const VendorTransactionHistoryScreen({super.key});

  @override
  State<VendorTransactionHistoryScreen> createState() =>
      _VendorTransactionHistoryScreenState();
}

class _VendorTransactionHistoryScreenState
    extends State<VendorTransactionHistoryScreen> {
  String selectedFilter = 'All';
  // Pending/Failed will always be empty today — transferMoney only ever
  // writes status: "completed" (it throws before writing anything on
  // failure). Kept for when a pending/async payment path exists.
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: uid == null
            ? const Center(child: Text('Not signed in.'))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('toUid', isEqualTo: uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: cs.primary));
                  }
                  if (snapshot.hasError) {
                    return _errorState(cs, () => setState(() {}));
                  }

                  final allTransactions = (snapshot.data?.docs ?? []).map(TransactionModel.fromFirestore).toList();
                  final totalSales = allTransactions
                      .where((t) => t.status == 'completed')
                      .fold(0.0, (total, t) => total + t.amount);
                  final pendingCount = allTransactions.where((t) => t.status == 'pending').length;
                  final transactions = _applyFilter(allTransactions);

                  return Column(
                    children: [
                      Row(
                        children: [
                          _summaryCard('Total Sales', '\$${totalSales.toStringAsFixed(2)}', Icons.attach_money, cs),
                          const SizedBox(width: 10),
                          _summaryCard('Transactions', '${allTransactions.length}', Icons.receipt_long, cs),
                          const SizedBox(width: 10),
                          _summaryCard('Pending', '$pendingCount', Icons.pending_actions, cs),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                                  border: selected ? null : Border.all(color: cs.outlineVariant),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: selected ? Colors.white : cs.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildList(cs, transactions)),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _errorState(ColorScheme cs, VoidCallback onRetry) {
    return AppErrorState(onRetry: onRetry);
  }

  Widget _buildList(ColorScheme cs, List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: selectedFilter == 'All' ? 'No transactions yet' : 'No $selectedFilter transactions',
        subtitle: selectedFilter == 'All'
            ? 'Transactions will appear here once customers pay.'
            : 'Try a different filter to see more results.',
      );
    }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final statusColor = _statusColor(tx.status);
        final name = tx.fromName.isNotEmpty ? tx.fromName : 'Customer';
        final hour = tx.createdAt.hour % 12 == 0 ? 12 : tx.createdAt.hour % 12;
        final period = tx.createdAt.hour >= 12 ? 'PM' : 'AM';
        return GestureDetector(
          onTap: () => context.push('/transaction-details', extra: {
            'id': tx.id,
            'fromName': name,
            'toName': tx.toName.isNotEmpty ? tx.toName : 'You',
            'amount': tx.amount,
            'status': tx.status[0].toUpperCase() + tx.status.substring(1),
            'createdAt': tx.createdAt,
            'description': tx.description,
          }),
          child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.primary.withValues(alpha: 0.1),
                        child: Text(name[0].toUpperCase(), style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(tx.description.isEmpty ? '—' : tx.description, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tx.status[0].toUpperCase() + tx.status.substring(1), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${tx.createdAt.month}/${tx.createdAt.day}/${tx.createdAt.year} at $hour:${tx.createdAt.minute.toString().padLeft(2, '0')} $period', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
