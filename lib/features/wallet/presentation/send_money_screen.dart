import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _recipientController = TextEditingController(text: 'Alex Johnson');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(text: 'Lunch split');

  final List<Map<String, String>> recentContacts = const [
    {'name': 'Alex Johnson', 'email': 'alex@montclair.edu', 'initial': 'A'},
    {'name': 'Sara Lee', 'email': 'sara@montclair.edu', 'initial': 'S'},
    {'name': 'Mike Chen', 'email': 'mike@montclair.edu', 'initial': 'M'},
  ];

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectRecipient(String name) {
    setState(() {
      _recipientController.text = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            const Text('Recipient', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _recipientController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search by name, email, or wallet ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Recent Contacts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recentContacts.map((contact) => GestureDetector(
                  onTap: () => _selectRecipient(contact['name']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _recipientController.text == contact['name']
                            ? const Color(0xFF8B1A2E)
                            : Colors.grey.shade100,
                        width: _recipientController.text == contact['name'] ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFFF0F0),
                          child: Text(
                            contact['initial']!,
                            style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(contact['email']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        if (_recipientController.text == contact['name'])
                          const Icon(Icons.check_circle, color: Color(0xFF8B1A2E))
                        else
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAmountField()),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickAmountPanel()),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Note', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              onChanged: (_) => setState(() {}),
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'What is this for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B1A2E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo transfer prepared. Connect payments later.')),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send Money', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: Colors.white,
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

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fast campus transfers', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 6),
          Text('Send Red Hawk Dollars instantly', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Demo mode only. Transfers will be connected to payments later.', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            filled: true,
            fillColor: Colors.white,
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B1A2E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountPanel() {
    final amounts = ['5', '10', '20', '50'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Pick', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: amounts
              .map((amount) => GestureDetector(
                    onTap: () => setState(() => _amountController.text = amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text('\$$amount', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transfer Preview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _summaryRow('To', _recipientController.text.isEmpty ? 'No recipient selected' : _recipientController.text),
          _summaryRow('Amount', _amountController.text.isEmpty ? '\$ 0.00' : '\$${_amountController.text}'),
          _summaryRow('Note', _noteController.text.isEmpty ? 'No note' : _noteController.text),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}