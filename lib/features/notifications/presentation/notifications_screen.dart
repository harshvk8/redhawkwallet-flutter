import 'package:flutter/material.dart';
import '../../../core/widgets/app_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  static const List<Map<String, String>> _notifications = [
    {'title': 'Wallet topped up', 'detail': 'Your demo wallet balance was updated.', 'time': '10 min ago', 'icon': 'wallet'},
    {'title': 'New offer available', 'detail': '10% Student Discount at Red Hawk Cafe.', 'time': '1 hr ago', 'icon': 'offer'},
    {'title': 'Verification reminder', 'detail': 'Add your university email to unlock rewards.', 'time': 'Today', 'icon': 'verify'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'offer': return Icons.local_offer_outlined;
      case 'verify': return Icons.school_outlined;
      default: return Icons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget body;
    if (_isLoading) {
      body = const AppLoadingState(message: 'Loading notifications…');
    } else if (_hasError) {
      body = AppErrorState(onRetry: _load);
    } else if (_notifications.isEmpty) {
      body = const AppEmptyState(
        icon: Icons.notifications_none_outlined,
        title: 'No notifications',
        subtitle: 'You\'re all caught up! Check back later.',
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
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
                  child: Icon(_icon(n['icon']!), color: cs.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                          Text(n['time']!, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n['detail']!, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: body,
    );
  }
}
