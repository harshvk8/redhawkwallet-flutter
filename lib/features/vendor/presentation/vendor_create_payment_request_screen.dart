import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorCreatePaymentRequestScreen extends StatefulWidget {
  const VendorCreatePaymentRequestScreen({super.key});

  @override
  State<VendorCreatePaymentRequestScreen> createState() => _VendorCreatePaymentRequestScreenState();
}

class _VendorCreatePaymentRequestScreenState extends State<VendorCreatePaymentRequestScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String selectedDiscount = 'No Discount';
  final List<String> discounts = ['No Discount', '10% Student Discount', 'Buy 1 Get 1', 'Free Delivery'];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Payment Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.primary),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Apply Offer or Discount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedDiscount,
              items: discounts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => selectedDiscount = val!),
            ),
            const SizedBox(height: 16),
            const Text('Note (optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'e.g. Table 4 coffee order'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final amount = _amountController.text.trim();
                  if (amount.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an amount'), backgroundColor: Colors.orange),
                    );
                    return;
                  }
                  context.push('/vendor/qr', extra: {
                    'amount': amount,
                    'note': _noteController.text.trim(),
                    'discount': selectedDiscount,
                  });
                },
                icon: const Icon(Icons.qr_code, size: 24),
                label: const Text('Generate QR Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
