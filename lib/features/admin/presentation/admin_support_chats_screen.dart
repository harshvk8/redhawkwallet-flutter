import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../support/services/support_chat_service.dart';

class AdminSupportChatsScreen extends StatefulWidget {
  const AdminSupportChatsScreen({super.key});

  @override
  State<AdminSupportChatsScreen> createState() => _AdminSupportChatsScreenState();
}

class _AdminSupportChatsScreenState extends State<AdminSupportChatsScreen> {
  final _service = SupportChatService();

  String _statusLabel(String status) => status == 'needs_human' ? 'Waiting' : 'Active';
  Color _statusColor(String status) => status == 'needs_human' ? Colors.orange : Colors.green;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Support Chats'), elevation: 0),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.chatsNeedingAttention(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load support chats.', style: TextStyle(color: cs.onSurfaceVariant)),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.support_agent, color: cs.onSurfaceVariant, size: 48),
                  const SizedBox(height: 8),
                  Text('No conversations need a human right now.', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final status = data['status'] as String? ?? 'needs_human';
              final userName = data['userName'] as String? ?? 'Student';
              final preview = data['lastMessagePreview'] as String? ?? '';
              final assignedAdminName = data['assignedAdminName'] as String?;
              final lastMessageAt = (data['lastMessageAt'] as Timestamp?)?.toDate();
              final timeLabel = lastMessageAt != null
                  ? '${lastMessageAt.month}/${lastMessageAt.day} ${lastMessageAt.hour.toString().padLeft(2, '0')}:${lastMessageAt.minute.toString().padLeft(2, '0')}'
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: InkWell(
                  onTap: () => context.push('/admin/support/chat', extra: doc.id),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.chat_bubble_outline, color: cs.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface), overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(preview, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              assignedAdminName != null ? 'With $assignedAdminName · $timeLabel' : timeLabel,
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
