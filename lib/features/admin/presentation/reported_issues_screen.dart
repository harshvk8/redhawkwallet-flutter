import 'package:flutter/material.dart';

class ReportedIssuesScreen extends StatefulWidget {
  const ReportedIssuesScreen({super.key});

  @override
  State<ReportedIssuesScreen> createState() => _ReportedIssuesScreenState();
}

class _ReportedIssuesScreenState extends State<ReportedIssuesScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Open', 'In Progress', 'Resolved'];

  final List<Map<String, dynamic>> _issues = [
    {
      'id': 'ISS-001',
      'title': 'Payment not received after QR scan',
      'category': 'Payment',
      'reporter': 'Alex Johnson',
      'date': 'Jun 30, 2026',
      'status': 'Open',
      'priority': 'High',
      'description': 'Scanned vendor QR, funds deducted from wallet but vendor says not received.',
    },
    {
      'id': 'ISS-002',
      'title': 'Cannot add university email — verification fails',
      'category': 'Verification',
      'reporter': 'Sara Lee',
      'date': 'Jun 29, 2026',
      'status': 'In Progress',
      'priority': 'Medium',
      'description': '.edu email entered correctly but verification email never arrives.',
    },
    {
      'id': 'ISS-003',
      'title': 'Vendor offer not showing on student app',
      'category': 'Offers',
      'reporter': 'Red Hawk Cafe',
      'date': 'Jun 28, 2026',
      'status': 'Open',
      'priority': 'Low',
      'description': 'Published a new offer 2 days ago but students report not seeing it.',
    },
    {
      'id': 'ISS-004',
      'title': 'Duplicate transaction charged twice',
      'category': 'Payment',
      'reporter': 'Mike Chen',
      'date': 'Jun 27, 2026',
      'status': 'Resolved',
      'priority': 'High',
      'description': 'Charged twice for same order at Hawks Pizza. Refund issued manually.',
    },
    {
      'id': 'ISS-005',
      'title': 'Dark mode toggle resets on restart',
      'category': 'UI Bug',
      'reporter': 'Priya Patel',
      'date': 'Jun 26, 2026',
      'status': 'Resolved',
      'priority': 'Low',
      'description': 'Dark mode preference not persisted between app sessions.',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _issues;
    return _issues.where((i) => i['status'] == _filter).toList();
  }

  Color _statusColor(String status) {
    if (status == 'Open') return Colors.red;
    if (status == 'In Progress') return Colors.orange;
    return Colors.green;
  }

  Color _priorityColor(String priority) {
    if (priority == 'High') return Colors.red;
    if (priority == 'Medium') return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final openCount = _issues.where((i) => i['status'] == 'Open').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Issues'),
        actions: [
          if (openCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: Text('$openCount open', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? cs.primary : Colors.grey.shade200),
                      ),
                      child: Text(f, style: TextStyle(color: selected ? Colors.white : cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 56, color: Colors.green.withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        Text('No issues in this category', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buildIssueCard(_filtered[i], cs),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> issue, ColorScheme cs) {
    final statusColor = _statusColor(issue['status'] as String);
    final priorityColor = _priorityColor(issue['priority'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(issue['id'] as String, style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(issue['priority'] as String, style: TextStyle(fontSize: 11, color: priorityColor, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(issue['status'] as String, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(issue['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(issue['description'] as String, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6), height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: Text(issue['category'] as String, style: TextStyle(fontSize: 11, color: cs.primary)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.person_outline, size: 13, color: cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text(issue['reporter'] as String, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
              const Spacer(),
              Text(issue['date'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          if (issue['status'] != 'Resolved') ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 8),
            Row(
              children: [
                if (issue['status'] == 'Open')
                  _actionButton('Mark In Progress', Colors.orange, () {
                    setState(() => issue['status'] = 'In Progress');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as In Progress')));
                  }),
                const SizedBox(width: 8),
                _actionButton('Mark Resolved', Colors.green, () {
                  setState(() => issue['status'] = 'Resolved');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue resolved')));
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
