import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const _colors = [Color(0xFF8B1A2E), Colors.blue, Colors.orange, Colors.green, Colors.teal, Colors.purple];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _approvedVendors(List<QueryDocumentSnapshot> docs) {
    return docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id,
            'name': data['businessName'] as String? ?? data['name'] as String? ?? 'Vendor',
            'category': data['businessCategory'] as String? ?? 'Other',
          };
        })
        .toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Browse Vendors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search vendors',
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Single equality + orderBy on a different field — no composite
              // index required. createdAt is set on every user doc, unlike
              // businessName, which older accounts may not have; the actual
              // alphabetical sort happens client-side in _approvedVendors.
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'vendor')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF8B1A2E)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load vendors.'));
                }
                final approvedDocs = (snapshot.data?.docs ?? [])
                    .where((d) => (d.data() as Map<String, dynamic>)['vendorStatus'] == 'approved')
                    .toList();
                final vendors = _approvedVendors(approvedDocs);
                final categories = ['All', ...{for (final v in vendors) v['category'] as String}];
                final query = _searchController.text.toLowerCase();
                final filtered = vendors.where((vendor) {
                  final matchesQuery = query.isEmpty || (vendor['name'] as String).toLowerCase().contains(query);
                  final matchesFilter = _selectedFilter == 'All' || vendor['category'] == _selectedFilter;
                  return matchesQuery && matchesFilter;
                }).toList();

                return Column(
                  children: [
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final filter = categories[index];
                          final isActive = filter == _selectedFilter;
                          return ChoiceChip(
                            label: Text(filter),
                            selected: isActive,
                            onSelected: (_) => setState(() => _selectedFilter = filter),
                            selectedColor: colorScheme.primary,
                            labelStyle: TextStyle(color: isActive ? colorScheme.onPrimary : colorScheme.onSurface),
                            backgroundColor: colorScheme.surface,
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemCount: categories.length,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text('No vendors found.', style: TextStyle(color: colorScheme.onSurfaceVariant)))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => _vendorCard(context, filtered[index], index),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _vendorCard(BuildContext context, Map<String, dynamic> vendor, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _colors[index % _colors.length];

    return InkWell(
      onTap: () => context.push('/vendors/details', extra: vendor),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.storefront, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor['name'] as String, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(vendor['category'] as String, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
