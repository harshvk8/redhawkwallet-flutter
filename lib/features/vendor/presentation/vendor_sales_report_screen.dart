import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../wallet/models/transaction_model.dart';

class VendorSalesReportScreen extends StatefulWidget {
  const VendorSalesReportScreen({super.key});

  @override
  State<VendorSalesReportScreen> createState() => _VendorSalesReportScreenState();
}

class _VendorSalesReportScreenState extends State<VendorSalesReportScreen> {
  String _period = 'Week';
  final _periods = ['Today', 'Week', 'Month', 'Year'];

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _topItems = [
    {'name': 'Latte (Large)', 'sold': 48, 'revenue': '\$192.00'},
    {'name': 'Sandwich Combo', 'sold': 31, 'revenue': '\$248.00'},
    {'name': 'Iced Coffee', 'sold': 27, 'revenue': '\$94.50'},
    {'name': 'Muffin', 'sold': 22, 'revenue': '\$55.00'},
    {'name': 'Breakfast Wrap', 'sold': 14, 'revenue': '\$126.00'},
  ];

  DateTime _periodStart(DateTime now) {
    switch (_period) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Month':
        return now.subtract(const Duration(days: 30));
      case 'Year':
        return now.subtract(const Duration(days: 365));
      case 'Week':
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  /// Last 7 calendar days' completed revenue, oldest first — the chart is
  /// always a trailing-7-day view regardless of the period filter above.
  List<Map<String, dynamic>> _last7DaysData(List<TransactionModel> completed) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final dayTotal = completed
          .where((t) =>
              t.createdAt.year == day.year && t.createdAt.month == day.month && t.createdAt.day == day.day)
          .fold(0.0, (total, t) => total + t.amount);
      return {'day': _weekdayLabels[day.weekday - 1], 'amount': dayTotal};
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Export coming in production'), backgroundColor: cs.primary),
              );
            },
          ),
        ],
      ),
      body: uid == null
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
                  return const Center(child: Text('Failed to load sales data.'));
                }

                final all = (snapshot.data?.docs ?? []).map(TransactionModel.fromFirestore).toList();
                final now = DateTime.now();
                final periodStart = _periodStart(now);
                final completedInPeriod = all
                    .where((t) => t.status == 'completed' && !t.createdAt.isBefore(periodStart))
                    .toList();
                final totalSales = completedInPeriod.fold(0.0, (total, t) => total + t.amount);
                final orderCount = completedInPeriod.length;
                final avgOrder = orderCount == 0 ? 0.0 : totalSales / orderCount;
                final weekData = _last7DaysData(all.where((t) => t.status == 'completed').toList());
                final maxAmount = weekData
                    .map((d) => d['amount'] as double)
                    .fold(0.0, (m, v) => v > m ? v : m);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(cs),
                      const SizedBox(height: 16),
                      _buildSummaryCards(cs, totalSales, orderCount, avgOrder),
                      const SizedBox(height: 20),
                      Text('Revenue Chart — Last 7 Days', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      const SizedBox(height: 12),
                      _buildBarChart(cs, weekData, maxAmount),
                      const SizedBox(height: 20),
                      Text('Top Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      const SizedBox(height: 12),
                      _buildTopItems(cs),
                      const SizedBox(height: 20),
                      _buildCategoryBreakdown(cs),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPeriodSelector(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: _periods.map((p) {
          final selected = p == _period;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  p,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(ColorScheme cs, double totalSales, int orderCount, double avgOrder) {
    return Row(
      children: [
        _summaryCard('Total Revenue', '\$${totalSales.toStringAsFixed(2)}', Icons.attach_money, cs, Colors.green),
        const SizedBox(width: 10),
        _summaryCard('Orders', '$orderCount', Icons.receipt_long, cs, cs.primary),
        const SizedBox(width: 10),
        _summaryCard('Avg Order', '\$${avgOrder.toStringAsFixed(2)}', Icons.trending_up, cs, Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, ColorScheme cs, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(ColorScheme cs, List<Map<String, dynamic>> weekData, double maxAmount) {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weekData.map((d) {
          final amount = d['amount'] as double;
          final heightFraction = maxAmount == 0 ? 0.0 : amount / maxAmount;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('\$${amount.toInt()}', style: TextStyle(fontSize: 9, color: cs.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 120 * heightFraction,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: heightFraction > 0.8 ? 1.0 : 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(d['day'] as String, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopItems(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: _topItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (i > 0) Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 0 ? Colors.amber.withValues(alpha: 0.15) : cs.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: i == 0 ? Colors.amber.shade700 : cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                          Text('${item['sold']} sold', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(item['revenue'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.primary)),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ColorScheme cs) {
    final categories = [
      {'name': 'Beverages', 'pct': 0.45, 'color': cs.primary},
      {'name': 'Food', 'pct': 0.32, 'color': Colors.orange},
      {'name': 'Snacks', 'pct': 0.15, 'color': Colors.green},
      {'name': 'Other', 'pct': 0.08, 'color': Colors.grey},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 14),
          ...categories.map((cat) {
            final pct = cat['pct'] as double;
            final color = cat['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(cat['name'] as String, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
