import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _period = 'Month';
  final _periods = ['Week', 'Month', 'Quarter', 'Year'];

  final _monthlyRevenue = [
    {'month': 'Jan', 'amount': 4200.0},
    {'month': 'Feb', 'amount': 5800.0},
    {'month': 'Mar', 'amount': 7100.0},
    {'month': 'Apr', 'amount': 6400.0},
    {'month': 'May', 'amount': 9200.0},
    {'month': 'Jun', 'amount': 8500.0},
  ];

  double get _maxAmount => _monthlyRevenue.map((d) => d['amount'] as double).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Export report — coming in production'), backgroundColor: cs.primary),
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
            _buildKpiRow(cs),
            const SizedBox(height: 20),
            Text('Revenue Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildRevenueChart(cs),
            const SizedBox(height: 20),
            Text('Platform Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildBreakdown(cs),
            const SizedBox(height: 20),
            Text('Top Vendors', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildTopVendors(cs),
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
        border: Border.all(color: cs.outlineVariant),
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
                    color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiRow(ColorScheme cs) {
    return Column(
      children: [
        Row(
          children: [
            _kpiCard('Total Revenue', '\$41,200', Icons.attach_money, Colors.green, '+18%', cs),
            const SizedBox(width: 10),
            _kpiCard('Transactions', '2,847', Icons.receipt_long, cs.primary, '+24%', cs),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _kpiCard('Active Users', '1,204', Icons.people_outline, Colors.orange, '+11%', cs),
            const SizedBox(width: 10),
            _kpiCard('Active Vendors', '34', Icons.storefront_outlined, Colors.purple, '+3', cs),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, String change, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
                  Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  Text(change, style: TextStyle(fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(ColorScheme cs) {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _monthlyRevenue.map((d) {
          final amount = d['amount'] as double;
          final heightFraction = amount / _maxAmount;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('\$${(amount / 1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 9, color: cs.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: 4),
                  Container(
                    height: 120 * heightFraction,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: heightFraction > 0.8 ? 1.0 : 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(d['month'] as String, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreakdown(ColorScheme cs) {
    final segments = [
      {'label': 'Student Payments', 'pct': 0.62, 'color': cs.primary, 'value': '\$25,544'},
      {'label': 'Vendor Sales', 'pct': 0.28, 'color': Colors.orange, 'value': '\$11,536'},
      {'label': 'Wallet Top-ups', 'pct': 0.10, 'color': Colors.green, 'value': '\$4,120'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: segments.map((s) {
          final pct = s['pct'] as double;
          final color = s['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s['label'] as String, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                        Text(s['value'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopVendors(ColorScheme cs) {
    final vendors = [
      {'name': 'Red Hawk Cafe', 'revenue': '\$8,240', 'txns': 412, 'growth': '+22%'},
      {'name': 'Campus Bookstore', 'revenue': '\$6,100', 'txns': 188, 'growth': '+9%'},
      {'name': 'Hawks Pizza', 'revenue': '\$4,800', 'txns': 267, 'growth': '+31%'},
      {'name': 'Campus Prints', 'revenue': '\$2,100', 'txns': 94, 'growth': '+5%'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: vendors.asMap().entries.map((entry) {
            final i = entry.key;
            final v = entry.value;
            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: cs.outlineVariant),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withValues(alpha: 0.1),
                    child: Text('${i + 1}', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(v['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                  subtitle: Text('${v['txns']} transactions', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(v['revenue'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
                      Text(v['growth'] as String, style: TextStyle(fontSize: 12, color: Colors.green.shade600, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
