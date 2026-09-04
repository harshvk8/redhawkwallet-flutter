import 'package:flutter/material.dart';

import '../../../core/theme/theme_notifier.dart';

class AuthDarkToggle extends StatelessWidget {
  final Color mutedBg;
  final bool isDark;
  const AuthDarkToggle({super.key, required this.mutedBg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier.instance,
            builder: (context, mode, _) {
              final isDarkNow = ThemeNotifier.instance.isDarkIn(context);
              return Material(
                color: mutedBg,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => ThemeNotifier.instance.toggle(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.dark_mode_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isDarkNow ? Icons.toggle_on : Icons.toggle_off,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthHawkLogo extends StatelessWidget {
  const AuthHawkLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HawkLogoPainter());
  }
}

class AuthInputLabel extends StatelessWidget {
  final String text;
  const AuthInputLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}

class AuthUniversityNote extends StatelessWidget {
  final Color mutedBg;
  final Color borderColor;
  final Color mutedText;
  const AuthUniversityNote({
    super.key,
    required this.mutedBg,
    required this.borderColor,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mutedBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Verify your university email later to unlock student features.',
              style: TextStyle(fontSize: 11, color: mutedText, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painters ────────────────────────────────────────────────────────────────

class _HawkLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.3, h * 0.35)
      ..lineTo(w * 0.3, h * 0.65)
      ..lineTo(w * 0.5, h * 0.8)
      ..lineTo(w * 0.7, h * 0.65)
      ..lineTo(w * 0.7, h * 0.35)
      ..close();
    canvas.drawPath(path, paint);

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.1,
      Paint()..color = const Color(0xFFCC0000),
    );
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}
