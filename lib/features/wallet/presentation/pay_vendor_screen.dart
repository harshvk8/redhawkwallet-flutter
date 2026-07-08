import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayVendorScreen extends StatefulWidget {
  const PayVendorScreen({super.key, this.vendor});

  final Map<String, dynamic>? vendor;

  @override
  State<PayVendorScreen> createState() => _PayVendorScreenState();
}

class _PayVendorScreenState extends State<PayVendorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(text: 'Campus lunch');

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor ?? const {
      'name': 'Browse a vendor',
      'category': 'Campus dining and retail',
      'rating': '4.8',
      'distance': 'On campus',
      'status': 'Open now',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Pay Vendor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _vendorHero(vendor),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/vendors'),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Browse Vendors'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _fieldCard('Amount', _buildAmountField())),
                const SizedBox(width: 12),
                Expanded(child: _fieldCard('Tip / Note', _buildNoteField())),
              ],
            ),
            const SizedBox(height: 16),
            _paymentMethods(),
            const SizedBox(height: 16),
            _summaryCard(vendor),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo payment submitted. Wire real payments later.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vendorHero(Map<String, dynamic> vendor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vendor['name'] as String? ?? 'Vendor', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(vendor['category'] as String? ?? 'Campus vendor', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(vendor['rating'] as String? ?? '4.8 stars'),
              _pill(vendor['distance'] as String? ?? 'Nearby'),
              _pill(vendor['status'] as String? ?? 'Open now'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _fieldCard(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      onChanged: (_) => setState(() {}),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        prefixText: '\$ ',
        filled: true,
        fillColor: Colors.white,
        hintText: '0.00',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      onChanged: (_) => setState(() {}),
      maxLines: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Add a tip or note',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _paymentMethods() {
    final methods = [
      {'icon': Icons.account_balance_wallet, 'name': 'Red Hawk Dollars'},
      {'icon': Icons.credit_card, 'name': 'Flex Dollars'},
      {'icon': Icons.stars, 'name': 'Points'},
    ];

    return Container(
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
          const Text('Pay with', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...methods.map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(method['icon'] as IconData, color: const Color(0xFF8B1A2E)),
                  const SizedBox(width: 10),
                  Text(method['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.check_circle_outline, color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
          const Text('Selection state is demo-only.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _summaryCard(Map<String, dynamic> vendor) {
    return Container(
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
          const Text('Payment Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row('Vendor', vendor['name'] as String? ?? 'Vendor'),
          _row('Amount', _amountController.text.isEmpty ? '\$ 0.00' : '\$${_amountController.text}'),
          _row('Note', _noteController.text.isEmpty ? 'No note' : _noteController.text),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}