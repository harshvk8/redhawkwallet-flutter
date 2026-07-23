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
  
  Map<String, dynamic>? _selectedVendor;

  final List<Map<String, String>> recentVendors = const [
    {'name': 'Red Hawk Cafe', 'category': 'Food & Drinks', 'initial': 'R', 'rating': '4.8', 'distance': 'On campus', 'status': 'Open now'},
    {'name': 'Campus Bookstore', 'category': 'Books & Supplies', 'initial': 'C', 'rating': '4.6', 'distance': 'Student Center', 'status': 'Open now'},
    {'name': 'Hawks Pizza', 'category': 'Food & Drinks', 'initial': 'H', 'rating': '4.9', 'distance': '0.2 miles', 'status': 'Open now'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedVendor = widget.vendor;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Pay Vendor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedVendor != null && widget.vendor == null) {
              setState(() => _selectedVendor = null);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _selectedVendor == null
            ? _buildVendorSelectionHub(context)
            : _buildPaymentForm(context, _selectedVendor!),
      ),
    );
  }

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
        const Text('Recent Vendors', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...recentVendors.map((vendor) => GestureDetector(
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
                  child: Text(vendor['initial']!, style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(vendor['category']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        )),
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