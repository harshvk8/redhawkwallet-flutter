import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorOffersScreen extends StatefulWidget {
  const VendorOffersScreen({super.key});

  @override
  State<VendorOffersScreen> createState() => _VendorOffersScreenState();
}

class _VendorOffersScreenState extends State<VendorOffersScreen> {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _openOfferForm({DocumentSnapshot? existing}) async {
    final data = existing?.data() as Map<String, dynamic>?;
    final titleController = TextEditingController(text: data?['title'] as String? ?? '');
    final descriptionController = TextEditingController(text: data?['description'] as String? ?? '');
    final discountController = TextEditingController(text: data?['discount'] as String? ?? '');
    final colorScheme = Theme.of(context).colorScheme;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add New Offer' : 'Edit Offer'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(controller: discountController, decoration: const InputDecoration(labelText: 'Discount (e.g. 10%, BOGO, FREE)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty || discountController.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;

    final now = Timestamp.fromDate(DateTime.now());
    if (existing == null) {
      final userDoc = await _db.collection('users').doc(_uid).get();
      final vendorName = (userDoc.data()?['businessName'] as String?) ?? (userDoc.data()?['name'] as String?) ?? 'Vendor';
      await _db.collection('offers').add({
        'vendorUid': _uid,
        'vendorName': vendorName,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'discount': discountController.text.trim(),
        'active': true,
        'usedCount': 0,
        'createdAt': now,
        'updatedAt': now,
      });
    } else {
      await existing.reference.update({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'discount': discountController.text.trim(),
        'updatedAt': now,
      });
    }
  }

  Future<void> _delete(DocumentSnapshot doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this offer?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await doc.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openOfferForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add New Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('offers').where('vendorUid', isEqualTo: _uid).orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load offers.'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text('No offers yet — tap "Add New Offer" to create one.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final offer = doc.data() as Map<String, dynamic>;
                      final active = offer['active'] as bool? ?? true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(offer['discount'] as String? ?? '', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(offer['title'] as String? ?? '', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: active,
                                  activeThumbColor: colorScheme.primary,
                                  onChanged: (val) => doc.reference.update({'active': val}),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(offer['description'] as String? ?? '', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Used ${offer['usedCount'] ?? 0} times', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                                Row(
                                  children: [
                                    TextButton(onPressed: () => _openOfferForm(existing: doc), child: Text('Edit', style: TextStyle(color: colorScheme.primary))),
                                    TextButton(onPressed: () => _delete(doc), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
