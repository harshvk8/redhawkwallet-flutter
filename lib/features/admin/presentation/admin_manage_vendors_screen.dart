import 'package:flutter/material.dart';

class AdminManageVendorsScreen extends StatefulWidget {
  const AdminManageVendorsScreen({super.key});

  @override
  State<AdminManageVendorsScreen> createState() => _AdminManageVendorsScreenState();
}

class _AdminManageVendorsScreenState extends State<AdminManageVendorsScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Active', 'Pending', 'Suspended'];

  final List<Map<String, dynamic>> vendors = [
    {
      'name': 'Red Hawk Cafe',
      'email': 'cafe@redhawk.edu',
      'category': 'Food & Drinks',
      'status': 'Active',
      'joined': 'May 10, 2026',
      'transactions': 42,
    },
    {
      'name': 'Campus Bookstore',
      'email': 'books@redhawk.edu',
      'category': 'Books & Supplies',
      'status': 'Pending',
      'joined': 'May 18, 2026',
      'transactions': 0,
    },
    {
      'name': 'Hawks Pizza',
      'email': 'pizza@redhawk.edu',
      'category': 'Food & Drinks',
      'status': 'Suspended',
      'joined': 'May 12, 2026',
      'transactions': 15,
    },
    {
      'name': 'Campus Prints',
      'email': 'prints@redhawk.edu',
      'category': 'Services',
      'status': 'Active',
      'joined': 'May 14, 2026',
      'transactions': 28,
    },
  ];

  Color _statusColor(String status) {
    if (status == 'Active') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.red;
  }

  List<Map<String, dynamic>> get filteredVendors {
    if (selectedFilter == 'All') return vendors;
    return vendors.where((v) => v['status'] == selectedFilter).toList();
  }

  void _showVendorDetails(BuildContext context, Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(vendor['email'], style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            _detailRow(Icons.category, 'Category', vendor['category']),
            _detailRow(Icons.calendar_today, 'Joined', vendor['joined']),
            _detailRow(Icons.receipt_long, 'Total Transactions', '${vendor['transactions']}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final realIndex = vendors.indexOf(vendor);
                      setState(() => vendors[realIndex]['status'] = 'Active');
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${vendor['name']} approved')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final realIndex = vendors.indexOf(vendor);
                      setState(() => vendors[realIndex]['status'] = 'Suspended');
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${vendor['name']} suspended')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Suspend'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFC8102E)),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Vendors'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFC8102E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVendors.length,
                itemBuilder: (context, index) {
                  final vendor = filteredVendors[index];
                  final statusColor = _statusColor(vendor['status']);
                  return GestureDetector(
                    onTap: () => _showVendorDetails(context, vendor),
                    child: Container(
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
                              Text(vendor['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(vendor['status'], style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(vendor['email'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(vendor['category'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final realIndex = vendors.indexOf(vendor);
                                  setState(() => vendors[realIndex]['status'] = 'Active');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${vendor['name']} approved')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Approve', style: TextStyle(fontSize: 13)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final realIndex = vendors.indexOf(vendor);
                                  setState(() => vendors[realIndex]['status'] = 'Suspended');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${vendor['name']} suspended')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Suspend', style: TextStyle(fontSize: 13)),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _showVendorDetails(context, vendor),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFC8102E),
                                  side: const BorderSide(color: Color(0xFFC8102E)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Details', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
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