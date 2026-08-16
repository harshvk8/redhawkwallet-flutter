import 'package:flutter/material.dart';

class VendorOffersScreen extends StatefulWidget {
  const VendorOffersScreen({super.key});

  @override
  State<VendorOffersScreen> createState() => _VendorOffersScreenState();
}

class _VendorOffersScreenState extends State<VendorOffersScreen> {
  final List<Map<String, dynamic>> offers = [
    {'title': '10% Student Discount', 'description': 'Valid for verified students', 'discount': '10%', 'used': 24, 'active': true},
    {'title': 'Buy 1 Get 1 Coffee', 'description': 'Every Monday only', 'discount': 'BOGO', 'used': 8, 'active': true},
    {'title': 'Free Delivery', 'description': 'Orders above \$15', 'discount': 'FREE', 'used': 5, 'active': false},
  ];

  Future<void> _openOfferForm({Map<String, dynamic>? existing, int? index}) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String?);
    final descriptionCtrl = TextEditingController(text: existing?['description'] as String?);
    final discountCtrl = TextEditingController(text: existing?['discount'] as String?);

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(existing == null ? 'New Offer' : 'Edit Offer'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descriptionCtrl, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: discountCtrl, decoration: const InputDecoration(labelText: 'Discount (e.g. 10%, BOGO)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: titleCtrl.text.trim().isEmpty ? null : () => Navigator.pop(ctx, true),
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      );

      if (result != true || !mounted) return;
      final offer = {
        'title': titleCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'discount': discountCtrl.text.trim().isEmpty ? '—' : discountCtrl.text.trim(),
        'used': existing?['used'] ?? 0,
        'active': existing?['active'] ?? true,
      };
      setState(() {
        if (index != null) {
          offers[index] = offer;
        } else {
          offers.insert(0, offer);
        }
      });
    } finally {
      titleCtrl.dispose();
      descriptionCtrl.dispose();
      discountCtrl.dispose();
    }
  }

  Future<void> _deleteOffer(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this offer?'),
        content: Text('"${offers[index]['title']}" will be removed.'),
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
    if (confirmed == true && mounted) setState(() => offers.removeAt(index));
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
              child: ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(offer['discount'], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 10),
                                Text(offer['title'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Switch(
                              value: offer['active'],
                              activeThumbColor: colorScheme.primary,
                              onChanged: (val) => setState(() => offers[index]['active'] = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(offer['description'], style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Used ${offer['used']} times', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Row(
                              children: [
                                TextButton(onPressed: () => _openOfferForm(existing: offer, index: index), child: Text('Edit', style: TextStyle(color: colorScheme.primary))),
                                TextButton(onPressed: () => _deleteOffer(index), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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