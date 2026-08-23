import 'package:flutter/material.dart';

/// A single chat bubble in a support conversation. Shared between the
/// user-facing and admin-facing chat screens so the two stay visually
/// consistent — [alignRight] flips which side is "self" for whichever side
/// is viewing (the user's own messages on the user screen; the admin's own
/// replies on the admin screen).
class SupportMessageBubble extends StatelessWidget {
  const SupportMessageBubble({
    super.key,
    required this.sender,
    required this.text,
    this.alignRight = 'user',
  });

  /// 'user' | 'assistant' | 'admin' | 'system'
  final String sender;
  final String text;

  /// Which sender value renders on the right, bubble-in-primary-color.
  final String alignRight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (sender == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(text, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic)),
        ),
      );
    }

    final isSelf = sender == alignRight;
    final isAdmin = sender == 'admin';
    final bubbleColor = isSelf ? cs.primary : (isAdmin ? cs.tertiaryContainer : cs.surfaceContainerHighest);
    final textColor = isSelf ? cs.onPrimary : (isAdmin ? cs.onTertiaryContainer : cs.onSurface);

    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin && !isSelf)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('Team Member', style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            Text(text, style: TextStyle(color: textColor, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
