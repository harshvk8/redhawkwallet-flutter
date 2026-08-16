import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorCreatePaymentRequestScreen extends StatefulWidget {
  const VendorCreatePaymentRequestScreen({super.key});

  @override
  State<VendorCreatePaymentRequestScreen> createState() => _VendorCreatePaymentRequestScreenState();
}

class _VendorCreatePaymentRequestScreenState extends State<VendorCreatePaymentRequestScreen> {
  String selectedDiscount = 'No Discount';
  final List<String> discounts = ['No Discount', '10% Student Discount', 'Buy 1 Get 1', 'Free Delivery'];
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment Request'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Apply Offer or Discount', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedDiscount,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              items: discounts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => selectedDiscount = val!),
            ),
            const SizedBox(height: 16),
            Text('Note (optional)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Table 4 coffee order',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text.trim());
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.orange),
                    );
                    return;
                  }
                  context.push('/vendor/qr', extra: {
                    'amount': amount,
                    'note': _noteController.text.trim().isEmpty ? selectedDiscount : _noteController.text.trim(),
                  });
                },
                icon: const Icon(Icons.qr_code, size: 24),
                label: const Text('Generate QR Code', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}