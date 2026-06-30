import 'package:flutter/material.dart';

enum DemoScreenStatus { loading, empty, error, ready }

class DemoScreenStateView extends StatelessWidget {
  final DemoScreenStatus status;
  final Widget child;
  final VoidCallback onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  const DemoScreenStateView({
    super.key,
    required this.status,
    required this.child,
    required this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'No items yet',
    this.emptyMessage = 'Nothing has been loaded for this screen yet.',
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DemoScreenStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case DemoScreenStatus.empty:
        return _StatusView(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
        );
      case DemoScreenStatus.error:
        return _StatusView(
          icon: Icons.error_outline,
          title: 'Something went wrong.',
          message: 'Try again.',
          actionLabel: 'Retry',
          onAction: onRetry,
        );
      case DemoScreenStatus.ready:
        return child;
    }
  }
}

class _StatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
