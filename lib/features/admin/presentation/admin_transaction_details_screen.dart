import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminTransactionDetailsScreen extends StatelessWidget {
  const AdminTransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final id = extra?['id'] as String? ?? '—';
    final fromName = extra?['fromName'] as String? ?? 'Unknown';
    final toName = extra?['toName'] as String? ?? 'Unknown';
    final amount = extra?['amount'] as double? ?? 0.0;
    final status = extra?['status'] as String? ?? 'Unknown';
    final description = extra?['description'] as String? ?? '';
    final createdAt = extra?['createdAt'] as DateTime? ?? DateTime.now();
    final hour = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final dateStr = '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    final timeStr = '$hour:${createdAt.minute.toString().padLeft(2, '0')} $period';
    final statusColor = status == 'Completed'
        ? Colors.green
        : status == 'Pending'
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFFF0F0),
                          child: Text(fromName.isNotEmpty ? fromName[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        const Text('From', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(fromName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Color(0xFFC8102E)),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFF0F0),
                          child: Icon(Icons.store, color: Color(0xFFC8102E)),
                        ),
                        const SizedBox(height: 8),
                        const Text('To', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(toName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transaction Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _detailRow('Amount', '\$${amount.toStringAsFixed(2)}'),
                  _detailRow('Date', dateStr),
                  _detailRow('Time', timeStr),
                  if (description.isNotEmpty) _detailRow('Note', description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
