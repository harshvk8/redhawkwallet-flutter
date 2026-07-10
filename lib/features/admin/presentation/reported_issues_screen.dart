import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportedIssuesScreen extends StatefulWidget {
  const ReportedIssuesScreen({super.key});

  @override
  State<ReportedIssuesScreen> createState() => _ReportedIssuesScreenState();
}

class _ReportedIssuesScreenState extends State<ReportedIssuesScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Open', 'Resolved'];

  final List<Map<String, dynamic>> issues = [
    {'title': 'Payment not received', 'reportedBy': 'Alex Johnson', 'date': 'May 27, 2026', 'status': 'Open'},
    {'title': 'Wrong amount charged', 'reportedBy': 'Sara Lee', 'date': 'May 26, 2026', 'status': 'Open'},
    {'title': 'Vendor not found', 'reportedBy': 'Mike Chen', 'date': 'May 25, 2026', 'status': 'Resolved'},
    {'title': 'App crashed during payment', 'reportedBy': 'Priya Patel', 'date': 'May 24, 2026', 'status': 'Resolved'},
  ];

  List<Map<String, dynamic>> get filteredIssues {
    if (selectedFilter == 'All') return issues;
    return issues.where((i) => i['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Reported Issues'),
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, x) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFC8102E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? const Color(0xFFC8102E) : Colors.grey.shade200),
                      ),
                      child: Text(filter, style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredIssues.length,
                itemBuilder: (context, index) {
                  final issue = filteredIssues[index];
                  final isOpen = issue['status'] == 'Open';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                                Icon(Icons.warning_amber, color: isOpen ? Colors.orange : Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(issue['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOpen ? Colors.orange.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(issue['status'], style: TextStyle(color: isOpen ? Colors.orange : Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Reported by ${issue['reportedBy']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(issue['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC8102E),
                            side: const BorderSide(color: Color(0xFFC8102E)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('View Details', style: TextStyle(fontSize: 13)),
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
