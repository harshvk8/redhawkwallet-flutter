import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, String>> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        recentTransactions = [
          {'name': 'Alex Johnson', 'amount': '\$12.50', 'time': '2 min ago', 'status': 'Paid'},
          {'name': 'Sara Lee', 'amount': '\$8.00', 'time': '15 min ago', 'status': 'Paid'},
          {'name': 'Mike Chen', 'amount': '\$22.00', 'time': '1 hr ago', 'status': 'Paid'},
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/vendor/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Red Hawk Cafe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Active Vendor', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 16),
                  Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Total Sales Today (Demo)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statCard('Orders', '0', Icons.receipt_long, cs),
                const SizedBox(width: 10),
                _statCard('Offers', '3', Icons.local_offer, cs),
                const SizedBox(width: 10),
                _statCard('Points Given', '0', Icons.stars, cs),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _quickAction(context, Icons.qr_code, 'Request Payment', '/vendor/payment-request', cs)),
                const SizedBox(width: 10),
                Expanded(child: _quickAction(context, Icons.local_offer, 'My Offers', '/vendor/offers', cs)),
                const SizedBox(width: 10),
                Expanded(child: _quickAction(context, Icons.history, 'History', '/vendor/transactions', cs)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTransactionsSection(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(ColorScheme cs) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: cs.primary),
        ),
      );
    }
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            const Text('Something went wrong.', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    if (recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text('No transactions yet', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Your transactions will appear here.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }
    return Column(
      children: recentTransactions.map((tx) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primary.withValues(alpha: 0.1),
                  child: Text(tx['name']![0], style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(tx['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(tx['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Text(tx['status']!, style: TextStyle(color: Colors.green.shade700, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _statCard(String label, String value, IconData icon, ColorScheme cs) {
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
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, String route, ColorScheme cs) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
