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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final vendor = widget.vendor ?? const {
      'name': 'Browse a vendor',
      'category': 'Campus dining and retail',
      'rating': '4.8',
      'distance': 'On campus',
      'status': 'Open now',
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Pay Vendor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _vendorHero(vendor, colorScheme),
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
                Expanded(child: _fieldCard(context, 'Amount', _buildAmountField())),
                const SizedBox(width: 12),
                Expanded(child: _fieldCard(context, 'Tip / Note', _buildNoteField())),
              ],
            ),
            const SizedBox(height: 16),
            _paymentMethods(context),
            const SizedBox(height: 16),
            _summaryCard(context, vendor),
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
                  foregroundColor: colorScheme.onPrimary,
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

  Widget _vendorHero(Map<String, dynamic> vendor, ColorScheme colorScheme) {

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
          Text(vendor['name'] as String? ?? 'Vendor', style: TextStyle(color: colorScheme.onPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(vendor['category'] as String? ?? 'Campus vendor', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(vendor['rating'] as String? ?? '4.8 stars', colorScheme),
              _pill(vendor['distance'] as String? ?? 'Nearby', colorScheme),
              _pill(vendor['status'] as String? ?? 'Open now', colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _fieldCard(BuildContext context, String label, Widget field) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildAmountField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _amountController,
      onChanged: (_) => setState(() {}),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        prefixText: '\$ ',
        filled: true,
        fillColor: colorScheme.surface,
        hintText: '0.00',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }

  Widget _buildNoteField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _noteController,
      onChanged: (_) => setState(() {}),
      maxLines: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface,
        hintText: 'Add a tip or note',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }

  Widget _paymentMethods(BuildContext context) {
    final methods = [
      {'icon': Icons.account_balance_wallet, 'name': 'Red Hawk Dollars'},
      {'icon': Icons.credit_card, 'name': 'Flex Dollars'},
      {'icon': Icons.stars, 'name': 'Points'},
    ];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay with', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...methods.map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(method['icon'] as IconData, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(method['name'] as String, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(Icons.check_circle_outline, color: colorScheme.onSurfaceVariant, size: 18),
                ],
              ),
            ),
          ),
          Text('Selection state is demo-only.', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, Map<String, dynamic> vendor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _row(context, 'Vendor', vendor['name'] as String? ?? 'Vendor'),
          _row(context, 'Amount', _amountController.text.isEmpty ? '\$ 0.00' : '\$${_amountController.text}'),
          _row(context, 'Note', _noteController.text.isEmpty ? 'No note' : _noteController.text),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}