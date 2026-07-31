import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _vendors = const [
    {'name': 'Red Hawk Cafe', 'category': 'Dining', 'rating': 4.8, 'distance': '0.2 mi', 'status': 'Open now', 'featured': true, 'color': Color(0xFF8B1A2E)},
    {'name': 'Campus Bookstore', 'category': 'Retail', 'rating': 4.6, 'distance': '0.4 mi', 'status': 'Open now', 'featured': false, 'color': Colors.blue},
    {'name': 'Hawks Pizza', 'category': 'Dining', 'rating': 4.7, 'distance': '0.6 mi', 'status': 'Open now', 'featured': true, 'color': Colors.orange},
    {'name': 'Campus Print Lab', 'category': 'Services', 'rating': 4.5, 'distance': '0.5 mi', 'status': 'Closes soon', 'featured': false, 'color': Colors.green},
    {'name': 'The Nest Market', 'category': 'Retail', 'rating': 4.9, 'distance': '0.8 mi', 'status': 'Open now', 'featured': true, 'color': Colors.teal},
  ];

  final List<String> _filters = const ['All', 'Dining', 'Retail', 'Services'];
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendors = _filteredVendors;
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
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final filter = _filters[index];
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
              itemCount: _filters.length,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: vendors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                return _vendorCard(context, vendor);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredVendors {
    final query = _searchController.text.toLowerCase();
    return _vendors.where((vendor) {
      final matchesQuery = query.isEmpty || (vendor['name'] as String).toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' || vendor['category'] == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Widget _vendorCard(BuildContext context, Map<String, dynamic> vendor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                color: (vendor['color'] as Color).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.storefront, color: vendor['color'] as Color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(vendor['name'] as String, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                      if (vendor['featured'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                          child: Text('Featured', style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(vendor['category'] as String, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${vendor['rating']}', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 12),
                      const Icon(Icons.place_outlined, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(vendor['distance'] as String, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}