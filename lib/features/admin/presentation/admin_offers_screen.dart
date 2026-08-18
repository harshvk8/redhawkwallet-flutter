import 'package:flutter/material.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final List<Map<String, String>> _offers = [
    {'title': '10% Student Discount', 'vendor': 'Red Hawk Cafe', 'discount': '10%', 'expiry': 'Jun 30, 2026', 'status': 'Active'},
    {'title': 'Buy 1 Get 1 Coffee', 'vendor': 'Red Hawk Cafe', 'discount': 'BOGO', 'expiry': 'Jun 15, 2026', 'status': 'Active'},
    {'title': 'Free Delivery', 'vendor': 'Hawks Pizza', 'discount': 'FREE', 'expiry': 'May 31, 2026', 'status': 'Pending'},
    {'title': '15% Off Books', 'vendor': 'Campus Bookstore', 'discount': '15%', 'expiry': 'Jun 1, 2026', 'status': 'Disabled'},
  ];

  Color _statusColor(String status) {
    if (status == 'Active') return Colors.green;
    if (status == 'Pending') return Colors.orange;
    return Colors.red;
  }

  void _setStatus(int index, String status) {
    setState(() => _offers[index] = {..._offers[index], 'status': status});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Offers'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _offers.length,
          itemBuilder: (context, index) {
            final offer = _offers[index];
            final status = offer['status']!;
            final statusColor = _statusColor(status);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
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
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(offer['discount']!, style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Text(offer['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(offer['vendor']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Expires: ${offer['expiry']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (status == 'Pending') ...[
                        ElevatedButton(
                          onPressed: () => _setStatus(index, 'Active'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            // Overrides the app-wide ElevatedButtonTheme's
                            // minimumSize: Size(double.infinity, 52) — two
                            // of these side by side in a bare Row would
                            // otherwise both demand full width and overflow.
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Approve', style: TextStyle(fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _setStatus(index, 'Disabled'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Reject', style: TextStyle(fontSize: 13)),
                        ),
                      ] else if (status == 'Active')
                        ElevatedButton(
                          onPressed: () => _setStatus(index, 'Disabled'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Disable', style: TextStyle(fontSize: 13)),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => _setStatus(index, 'Active'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Enable', style: TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
