import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/services/user_service.dart';
import '../services/money_transfer_service.dart';

/// Recipients eligible for a casual P2P transfer: university-verified
/// students in good standing. Keyed off isUniversityVerified rather than
/// role=='verified_student' — the two are supposed to be set atomically
/// (see UserService.updateUniversityVerification) but role can lag on older
/// or manually-edited records, which would otherwise make a genuinely
/// verified user unfindable here. Vendors/admins are excluded since they
/// have their own dedicated flows, and suspended accounts aren't payable
/// here. A missing accountStatus field means "active" everywhere else in
/// this app (UserModel's parser, the router's suspend check), so this
/// matches that convention rather than requiring the field to be explicitly
/// set.
bool _isApprovedRecipientData(Map<String, dynamic> data) =>
    data['isUniversityVerified'] == true &&
    data['role'] != 'vendor' &&
    data['role'] != 'admin' &&
    data['accountStatus'] != 'suspended';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _recipientUid;
  String? _recipientName;
  bool _searching = false;
  bool _sending = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
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

  /// A query counts as a phone number once it's nothing but digits and
  /// common phone punctuation ((), -, +, spaces) with 7+ digits — enough to
  /// match "(555) 123-4567" while still treating plain names as names.
  bool _looksLikePhone(String query) {
    if (!RegExp(r'^[0-9()\-+.\s]+$').hasMatch(query)) return false;
    final digits = query.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7;
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!query.contains('@') && !_looksLikePhone(query)) {
      // Plain name — the "Approved Recipients" list below already filters
      // live as the user types, so there's no separate lookup to run.
      setState(() => _searchError = null);
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final field = query.contains('@') ? 'email' : 'phoneNumber';
      final value = query.contains('@') ? query.toLowerCase() : UserService.normalizePhone(query);
      if (value.isEmpty) {
        setState(() => _searchError = 'Enter a valid phone number or email.');
        return;
      }
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where(field, isEqualTo: value)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() => _searchError = 'No account found for "$query".');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Send Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(colorScheme),
            const SizedBox(height: 16),
            Text('Find a recipient', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                suffixIcon: _searching
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _search),
                filled: true,
                fillColor: colorScheme.surface,
                hintText: 'Phone, email, or name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B1A2E), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(_recipientName!.isNotEmpty ? _recipientName![0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_recipientName!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                    const Icon(Icons.check_circle, color: Color(0xFF8B1A2E)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text('Approved Recipients', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Verified students only. No contact info shown.', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            if (uid == null)
              Text('Not signed in.', style: TextStyle(color: colorScheme.onSurfaceVariant))
            else
              _approvedRecipientsList(uid),
            const SizedBox(height: 16),
            Text('Recent Contacts', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (uid == null)
              Text('Not signed in.', style: TextStyle(color: colorScheme.onSurfaceVariant))
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
                    return Text('No recent contacts yet.', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant));
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
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? const Color(0xFF8B1A2E) : colorScheme.outlineVariant,
                              width: selected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                child: Text(
                                  contact['name']!.isNotEmpty ? contact['name']![0].toUpperCase() : '?',
                                  style: const TextStyle(color: Color(0xFF8B1A2E), fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(contact['name']!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                              if (selected)
                                const Icon(Icons.check_circle, color: Color(0xFF8B1A2E))
                              else
                                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
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
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                hintText: 'Add a note for the transfer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                    : const Icon(Icons.send),
                label: const Text('Send Money', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A2E),
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
      // Equality + orderBy on a different field needs the composite index
      // in firestore.indexes.json (isUniversityVerified + createdAt).
      // role/accountStatus are filtered client-side below.
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('isUniversityVerified', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator());
        }
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final rawQuery = _searchController.text.trim();
        final nameFilter = (rawQuery.contains('@') || _looksLikePhone(rawQuery)) ? '' : rawQuery.toLowerCase();
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
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
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

  Widget _headerCard(ColorScheme colorScheme) {
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
          Text('Fast campus transfers', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 13)),
          const SizedBox(height: 6),
          Text('Send Red Hawk Dollars instantly', style: TextStyle(color: colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
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
        ),
      ],
    );
  }

  Widget _buildQuickAmountPanel() {
    final amounts = ['5', '10', '20', '50'];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Pick', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amounts
              .map((amount) => GestureDetector(
                    onTap: () => setState(() => _amountController.text = amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text('\$$amount', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
          Text('Transfer Preview', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _summaryRow('To', _recipientName ?? 'No recipient selected'),
          _summaryRow('Amount', _amountController.text.isEmpty ? '\$ 0.00' : '\$${_amountController.text}'),
          _summaryRow('Note', _noteController.text.isEmpty ? 'No note' : _noteController.text),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
