import 'package:flutter/material.dart';

class UserEventsScreen extends StatelessWidget {
  const UserEventsScreen({super.key});

  final List<Map<String, String>> events = const [
    {'title': 'Campus Tech Fair', 'date': 'Jun 5, 2026', 'time': '10:00 AM', 'location': 'Student Center'},
    {'title': 'Food Truck Friday', 'date': 'Jun 7, 2026', 'time': '11:00 AM', 'location': 'Main Quad'},
    {'title': 'Student Market', 'date': 'Jun 12, 2026', 'time': '9:00 AM', 'location': 'Campus Plaza'},
    {'title': 'Hawks Game Night', 'date': 'Jun 14, 2026', 'time': '6:00 PM', 'location': 'Recreation Center'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A2E),
        foregroundColor: Colors.white,
        title: const Text('Campus Events'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.event, color: Color(0xFF8B1A2E), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(event['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${event['date']} at ${event['time']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(event['location']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Check In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1A2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
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