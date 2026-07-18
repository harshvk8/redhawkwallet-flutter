import 'package:flutter/material.dart';

/// Centered loading spinner with an optional message.
/// Use while awaiting async data.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.55)),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly empty state with icon, title, subtitle, and optional action button.
/// Use when a list or data source returns zero items.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5), height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with icon, message, and retry button.
/// Use when an async operation fails.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.message = 'Something went wrong. Please try again.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 36, color: cs.error.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55), height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
