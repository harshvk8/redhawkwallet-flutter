import 'package:flutter/material.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  final List<Map<String, String>> events = const [
    {'title': 'Campus Tech Fair', 'date': 'Jun 5, 2026', 'time': '10:00 AM', 'location': 'Student Center', 'createdBy': 'Admin', 'status': 'Active'},
    {'title': 'Food Truck Friday', 'date': 'Jun 7, 2026', 'time': '11:00 AM', 'location': 'Main Quad', 'createdBy': 'Red Hawk Cafe', 'status': 'Active'},
    {'title': 'Student Market', 'date': 'Jun 12, 2026', 'time': '9:00 AM', 'location': 'Campus Plaza', 'createdBy': 'Admin', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isActive = event['status'] == 'Active';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(event['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(event['status']!, style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${event['date']} at ${event['time']}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(event['location']!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Created by ${event['createdBy']}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text('Disable', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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