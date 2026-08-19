import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${time.month}/${time.day}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: uid == null
          ? Center(child: Text('Not signed in.', style: TextStyle(color: cs.onSurfaceVariant)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('uid', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong loading notifications.', style: TextStyle(color: cs.onSurfaceVariant)),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none, size: 48, color: cs.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text('No notifications yet.', style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final read = data['read'] as bool? ?? false;
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: read ? null : () => doc.reference.update({'read': true}),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: read ? Colors.grey.shade100 : cs.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.notifications_none, color: cs.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['title'] as String? ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                                  const SizedBox(height: 4),
                                  Text(data['detail'] as String? ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Text(createdAt != null ? _timeAgo(createdAt) : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (!read)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: docs.length,
                );
              },
            ),
    );
  }
}
