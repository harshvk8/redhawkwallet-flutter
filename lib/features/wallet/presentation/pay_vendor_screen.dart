import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/money_transfer_service.dart';

class PayVendorScreen extends StatefulWidget {
  const PayVendorScreen({super.key, this.vendor});

  final Map<String, dynamic>? vendor;

  @override
  State<PayVendorScreen> createState() => _PayVendorScreenState();
}

class _PayVendorScreenState extends State<PayVendorScreen> {
  final TextEditingController _amountController = TextEditingController();
<<<<<<< HEAD
  final TextEditingController _noteController = TextEditingController(text: 'Campus lunch');
=======
  final TextEditingController _noteController = TextEditingController();

  Map<String, dynamic>? _selectedVendor;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _selectedVendor = widget.vendor;
  }
>>>>>>> origin/dev

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pay(Map<String, dynamic> vendor) async {
    final vendorUid = vendor['uid'] as String?;
    if (vendorUid == null || vendorUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This vendor is missing an account id.'), backgroundColor: Colors.red),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.orange),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pay \$${amount.toStringAsFixed(2)} to ${vendor['name']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B1A2E), foregroundColor: Colors.white),
            child: const Text('Pay'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _paying = true);
    try {
      await MoneyTransferService().transfer(
        toUid: vendorUid,
        amount: amount,
        note: _noteController.text.trim(),
        type: 'payment',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paid \$${amount.toStringAsFixed(2)} to ${vendor['name']}'), backgroundColor: const Color(0xFF8B1A2E)),
        );
        context.pop();
      }
    } on MoneyTransferException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
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

<<<<<<< HEAD
  Widget _vendorHero(Map<String, dynamic> vendor, ColorScheme colorScheme) {

=======
  // View shown when no specific vendor is active
  Widget _buildVendorSelectionHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/qr-scanner'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B1A2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scan Vendor QR Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Point your camera at vendor QR code', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/vendors'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8B1A2E)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Color(0xFF8B1A2E), size: 36),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Vendor', style: TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Find vendor by name or ID', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Vendors', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'vendor')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator(color: Color(0xFF8B1A2E))));
            }
            final docs = (snapshot.data?.docs ?? [])
                .where((d) => (d.data() as Map<String, dynamic>)['vendorStatus'] == 'approved')
                .toList();
            if (docs.isEmpty) {
              return const Text('No approved vendors yet.', style: TextStyle(color: Colors.grey));
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['businessName'] as String? ?? data['name'] as String? ?? 'Vendor';
                final category = data['businessCategory'] as String? ?? 'Other';
                final vendor = {'uid': doc.id, 'name': name, 'category': category};
                return GestureDetector(
                  onTap: () => setState(() => _selectedVendor = vendor),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFFF0F0),
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Form shown when a vendor is selected
  Widget _buildPaymentForm(BuildContext context, Map<String, dynamic> vendor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _vendorHero(vendor),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/vendors'),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Browse Other Vendors'),
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
            onPressed: _paying ? null : () => _pay(vendor),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1A2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _paying
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Pay Now'),
          ),
        ),
      ],
    );
  }

  Widget _vendorHero(Map<String, dynamic> vendor) {
>>>>>>> origin/dev
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
<<<<<<< HEAD
            children: [
              _pill(vendor['rating'] as String? ?? '4.8 stars', colorScheme),
              _pill(vendor['distance'] as String? ?? 'Nearby', colorScheme),
              _pill(vendor['status'] as String? ?? 'Open now', colorScheme),
            ],
=======
            children: [_pill('Approved vendor')],
>>>>>>> origin/dev
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
      {'icon': Icons.account_balance_wallet, 'name': 'Red Hawk Dollars', 'enabled': true},
      {'icon': Icons.credit_card, 'name': 'Flex Dollars', 'enabled': false},
      {'icon': Icons.stars, 'name': 'Points', 'enabled': false},
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
<<<<<<< HEAD
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
=======
          ...methods.map((method) {
            final enabled = method['enabled'] as bool;
            return Opacity(
              opacity: enabled ? 1.0 : 0.4,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(method['icon'] as IconData, color: const Color(0xFF8B1A2E)),
                    const SizedBox(width: 10),
                    Text(method['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    enabled
                        ? const Icon(Icons.check_circle, color: Color(0xFF8B1A2E), size: 18)
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Coming soon', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ),
                  ],
                ),
              ),
            );
          }),
          const Text('Selection state is demo-only.', style: TextStyle(color: Colors.grey, fontSize: 12)),
>>>>>>> origin/dev
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