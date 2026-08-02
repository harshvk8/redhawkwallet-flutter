import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/services/user_service.dart';
import '../services/money_transfer_service.dart';

/// Recipients eligible for a casual P2P transfer: verified students in good
/// standing. Vendors have their own dedicated Pay Vendor flow, and suspended
/// accounts aren't payable here. A missing accountStatus field means "active"
/// everywhere else in this app (UserModel's parser, the router's suspend
/// check), so this matches that convention rather than requiring the field
/// to be explicitly set.
bool _isApprovedRecipientData(Map<String, dynamic> data) =>
    data['role'] == 'verified_student' && data['accountStatus'] != 'suspended';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _recipientUid;
  String? _recipientName;
  bool _searching = false;
  bool _sending = false;
  String? _searchError;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameFilterController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectRecipient(String uid, String name) {
    setState(() {
      _recipientUid = uid;
      _recipientName = name;
      _searchError = null;
    });
  }

  Future<void> _searchByPhone() async {
    final phone = UserService.normalizePhone(_phoneController.text.trim());
    if (phone.isEmpty) return;
    final currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phone)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() => _searchError = 'No account found for that phone number.');
        return;
      }
      final doc = snap.docs.first;
      if (doc.id == currentUser?.uid) {
        setState(() => _searchError = "You can't send money to yourself.");
        return;
      }
      final data = doc.data();
      if (!_isApprovedRecipientData(data)) {
        setState(() => _searchError = 'That account is not eligible to receive transfers.');
        return;
      }
      _selectRecipient(doc.id, data['name'] as String? ?? 'User');
    } catch (e) {
      setState(() => _searchError = 'Search failed: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _send() async {
    if (_recipientUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a recipient first'), backgroundColor: Colors.orange),
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
        title: Text('Send \$${amount.toStringAsFixed(2)} to $_recipientName?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B1A2E), foregroundColor: Colors.white),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      await MoneyTransferService().transfer(
        toUid: _recipientUid!,
        amount: amount,
        note: _noteController.text.trim(),
        type: 'transfer',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent \$${amount.toStringAsFixed(2)} to $_recipientName'), backgroundColor: const Color(0xFF8B1A2E)),
        );
        context.pop();
      }
    } on MoneyTransferException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
            const Text('Enter phone number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _searchByPhone(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                suffixIcon: _searching
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _searchByPhone),
                filled: true,
                fillColor: Colors.white,
                hintText: '(555) 123-4567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            if (_searchError != null) ...[
              const SizedBox(height: 6),
              Text(_searchError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            if (_recipientUid != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B1A2E), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFFF0F0),
                      child: Text(_recipientName!.isNotEmpty ? _recipientName![0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_recipientName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    const Icon(Icons.check_circle, color: Color(0xFF8B1A2E)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Approved Recipients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Verified students only. No contact info shown.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameFilterController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search by name',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 8),
            if (uid == null) const Text('Not signed in.', style: TextStyle(color: Colors.grey)) else _approvedRecipientsList(uid),
            const SizedBox(height: 16),
            const Text('Recent Contacts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (uid == null)
              const Text('Not signed in.', style: TextStyle(color: Colors.grey))
            else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('fromUid', isEqualTo: uid)
                    .orderBy('createdAt', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator());
                  }
                  final seen = <String>{};
                  final contacts = <Map<String, String>>[];
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['type'] != 'transfer') continue;
                    final toUid = data['toUid'] as String? ?? '';
                    if (toUid.isEmpty || !seen.add(toUid)) continue;
                    contacts.add({'uid': toUid, 'name': data['toName'] as String? ?? 'User'});
                    if (contacts.length >= 5) break;
                  }
                  if (contacts.isEmpty) {
                    return const Text('No recent contacts yet.', style: TextStyle(color: Colors.grey, fontSize: 13));
                  }
                  return Column(
                    children: contacts.map((contact) {
                      final selected = _recipientUid == contact['uid'];
                      return GestureDetector(
                        onTap: () => _selectRecipient(contact['uid']!, contact['name']!),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? const Color(0xFF8B1A2E) : Colors.grey.shade100,
                              width: selected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFFFF0F0),
                                child: Text(
                                  contact['name']!.isNotEmpty ? contact['name']![0].toUpperCase() : '?',
                                  style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                              if (selected)
                                const Icon(Icons.check_circle, color: Color(0xFF8B1A2E))
                              else
                                const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
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
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
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

  Widget _approvedRecipientsList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      // Single equality + orderBy on a different field — no composite index
      // required. accountStatus is filtered client-side below.
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'verified_student')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator());
        }
        final nameFilter = _nameFilterController.text.trim().toLowerCase();
        final recipients = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return doc.id != uid && _isApprovedRecipientData(data);
        }).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'uid': doc.id, 'name': data['name'] as String? ?? 'User'};
        }).where((recipient) {
          return nameFilter.isEmpty || (recipient['name'] as String).toLowerCase().contains(nameFilter);
        }).toList()
          ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

        if (recipients.isEmpty) {
          return Text(
            nameFilter.isEmpty ? 'No approved recipients yet.' : 'No approved recipients match "$nameFilter".',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          );
        }
        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recipients.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final recipient = recipients[index];
              final name = recipient['name']!;
              final selected = _recipientUid == recipient['uid'];
              return GestureDetector(
                onTap: () => _selectRecipient(recipient['uid']!, recipient['name']!),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFFFF0F0),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 2),
                        const Icon(Icons.check_circle, color: Color(0xFF8B1A2E), size: 14),
                      ] else
                        const SizedBox(height: 18),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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
          _summaryRow('To', _recipientName ?? 'No recipient selected'),
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
