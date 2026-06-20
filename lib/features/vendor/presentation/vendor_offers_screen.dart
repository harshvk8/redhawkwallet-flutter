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

  void _showOfferDialog(BuildContext context, {int? existingIndex}) {
    final isEdit = existingIndex != null;
    final titleCtrl = TextEditingController(text: isEdit ? offers[existingIndex]['title'] : '');
    final descCtrl = TextEditingController(text: isEdit ? offers[existingIndex]['description'] : '');
    final discountCtrl = TextEditingController(text: isEdit ? offers[existingIndex]['discount'] : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Offer' : 'New Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 8),
            TextField(controller: discountCtrl, decoration: const InputDecoration(labelText: 'Discount (e.g. 10%, BOGO, FREE)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                if (isEdit) {
                  offers[existingIndex]['title'] = titleCtrl.text.trim();
                  offers[existingIndex]['description'] = descCtrl.text.trim();
                  offers[existingIndex]['discount'] = discountCtrl.text.trim();
                } else {
                  offers.add({
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'discount': discountCtrl.text.trim(),
                    'used': 0,
                    'active': true,
                  });
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Offer updated' : 'Offer added'),
                  backgroundColor: const Color(0xFFC8102E),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC8102E), foregroundColor: Colors.white),
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showOfferDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add New Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8102E),
                  foregroundColor: Colors.white,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
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
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(offer['discount'], style: const TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 10),
                                Text(offer['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            Switch(
                              value: offer['active'],
                              activeThumbColor: const Color(0xFFC8102E),
                              onChanged: (val) => setState(() => offers[index]['active'] = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(offer['description'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Used ${offer['used']} times', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => _showOfferDialog(context, existingIndex: index),
                                  child: const Text('Edit', style: TextStyle(color: Color(0xFFC8102E))),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => offers.removeAt(index));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Offer deleted'), backgroundColor: Colors.red),
                                    );
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
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