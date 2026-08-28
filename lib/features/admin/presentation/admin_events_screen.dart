import 'package:flutter/material.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final List<Map<String, String>> _events = [
    {'title': 'Campus Tech Fair', 'date': 'Jun 5, 2026', 'time': '10:00 AM', 'location': 'Student Center', 'createdBy': 'Admin', 'status': 'Active'},
    {'title': 'Food Truck Friday', 'date': 'Jun 7, 2026', 'time': '11:00 AM', 'location': 'Main Quad', 'createdBy': 'Red Hawk Cafe', 'status': 'Active'},
    {'title': 'Student Market', 'date': 'Jun 12, 2026', 'time': '9:00 AM', 'location': 'Campus Plaza', 'createdBy': 'Admin', 'status': 'Pending'},
  ];

  Future<void> _openEventForm({Map<String, String>? existing, int? index}) async {
    final titleCtrl = TextEditingController(text: existing?['title']);
    final dateCtrl = TextEditingController(text: existing?['date']);
    final timeCtrl = TextEditingController(text: existing?['time']);
    final locationCtrl = TextEditingController(text: existing?['location']);

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(existing == null ? 'New Event' : 'Edit Event'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time')),
                TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
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
      final event = {
        'title': titleCtrl.text.trim(),
        'date': dateCtrl.text.trim().isEmpty ? 'TBD' : dateCtrl.text.trim(),
        'time': timeCtrl.text.trim().isEmpty ? 'TBD' : timeCtrl.text.trim(),
        'location': locationCtrl.text.trim().isEmpty ? 'TBD' : locationCtrl.text.trim(),
        'createdBy': existing?['createdBy'] ?? 'Admin',
        'status': existing?['status'] ?? 'Pending',
      };
      setState(() {
        if (index != null) {
          _events[index] = event;
        } else {
          _events.insert(0, event);
        }
      });
    } finally {
      titleCtrl.dispose();
      dateCtrl.dispose();
      timeCtrl.dispose();
      locationCtrl.dispose();
    }
  }

  void _toggleStatus(int index) {
    setState(() {
      final current = _events[index]['status'];
      _events[index] = {..._events[index], 'status': current == 'Active' ? 'Disabled' : 'Active'};
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openEventForm()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
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
                        onPressed: () => _openEventForm(existing: event, index: index),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
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
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _toggleStatus(index),
                        icon: Icon(isActive ? Icons.block : Icons.check_circle_outline, size: 16),
                        label: Text(isActive ? 'Disable' : 'Enable', style: const TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurface,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
