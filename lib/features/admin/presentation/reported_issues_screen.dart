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

  void _showIssueDetail(BuildContext context, Map<String, dynamic> issue) {
    final isOpen = issue['status'] == 'Open';
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: isOpen ? Colors.orange : Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(issue['title'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(issue['status'] as String, style: TextStyle(color: isOpen ? Colors.orange : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(cs, Icons.person_outline, 'Reported by', issue['reportedBy'] as String),
            _detailRow(cs, Icons.calendar_today_outlined, 'Date', issue['date'] as String),
            _detailRow(cs, Icons.info_outline, 'Status', issue['status'] as String),
            const SizedBox(height: 16),
            Text('Resolution coming post-MVP. Track via support queue.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(ColorScheme cs, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
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
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFC8102E) : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? const Color(0xFFC8102E) : cs.outlineVariant),
                      ),
                      child: Text(filter, style: TextStyle(color: selected ? Colors.white : cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
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
                            Row(
                              children: [
                                Icon(Icons.warning_amber, color: isOpen ? Colors.orange : Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(issue['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
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
                        Text('Reported by ${issue['reportedBy']}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        Text(issue['date'], style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => _showIssueDetail(context, issue),
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
