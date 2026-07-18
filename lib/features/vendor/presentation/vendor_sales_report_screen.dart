import 'package:flutter/material.dart';

class VendorSalesReportScreen extends StatefulWidget {
  const VendorSalesReportScreen({super.key});

  @override
  State<VendorSalesReportScreen> createState() => _VendorSalesReportScreenState();
}

class _VendorSalesReportScreenState extends State<VendorSalesReportScreen> {
  String _period = 'Week';
  final _periods = ['Today', 'Week', 'Month', 'Year'];

  final _weekData = [
    {'day': 'Mon', 'amount': 120.0},
    {'day': 'Tue', 'amount': 185.0},
    {'day': 'Wed', 'amount': 95.0},
    {'day': 'Thu', 'amount': 210.0},
    {'day': 'Fri', 'amount': 340.0},
    {'day': 'Sat', 'amount': 280.0},
    {'day': 'Sun', 'amount': 60.0},
  ];

  final _topItems = [
    {'name': 'Latte (Large)', 'sold': 48, 'revenue': '\$192.00'},
    {'name': 'Sandwich Combo', 'sold': 31, 'revenue': '\$248.00'},
    {'name': 'Iced Coffee', 'sold': 27, 'revenue': '\$94.50'},
    {'name': 'Muffin', 'sold': 22, 'revenue': '\$55.00'},
    {'name': 'Breakfast Wrap', 'sold': 14, 'revenue': '\$126.00'},
  ];

  double get _totalSales => _weekData.fold(0, (sum, d) => sum + (d['amount'] as double));
  double get _maxAmount => _weekData.map((d) => d['amount'] as double).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(cs),
            const SizedBox(height: 16),
            _buildSummaryCards(cs),
            const SizedBox(height: 20),
            Text('Revenue Chart', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildBarChart(cs),
            const SizedBox(height: 20),
            Text('Top Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildTopItems(cs),
            const SizedBox(height: 20),
            _buildCategoryBreakdown(cs),
          ],
        ),
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

  Widget _buildSummaryCards(ColorScheme cs) {
    return Row(
      children: [
        _summaryCard('Total Revenue', '\$${_totalSales.toStringAsFixed(2)}', Icons.attach_money, cs, Colors.green),
        const SizedBox(width: 10),
        _summaryCard('Orders', '142', Icons.receipt_long, cs, cs.primary),
        const SizedBox(width: 10),
        _summaryCard('Avg Order', '\$${(_totalSales / 142).toStringAsFixed(2)}', Icons.trending_up, cs, Colors.orange),
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

  Widget _buildBarChart(ColorScheme cs) {
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
        children: _weekData.map((d) {
          final amount = d['amount'] as double;
          final heightFraction = amount / _maxAmount;
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
