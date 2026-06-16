import 'package:flutter/material.dart';

import '../../../core/theme/theme_notifier.dart';

class AuthDarkToggle extends StatelessWidget {
  final Color mutedBg;
  final bool isDark;
  const AuthDarkToggle({super.key, required this.mutedBg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier.instance,
            builder: (context, mode, _) => Material(
              color: mutedBg,
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: ThemeNotifier.instance.toggle,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    mode == ThemeMode.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
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

class AuthOrDivider extends StatelessWidget {
  final Color mutedText;
  final Color borderColor;
  const AuthOrDivider(
      {super.key, required this.mutedText, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: borderColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(fontSize: 13, color: mutedText)),
        ),
        Expanded(child: Divider(color: borderColor, height: 1)),
      ],
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color borderColor;
  final Color cardColor;
  final Color mutedBg;
  final Widget child;
  const AuthSocialButton({
    super.key,
    required this.onTap,
    required this.borderColor,
    required this.cardColor,
    required this.mutedBg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        hoverColor: mutedBg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
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

class AuthGoogleLogo extends StatelessWidget {
  const AuthGoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
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

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    void arc(Color color, double start, double sweep) {
      canvas.drawArc(rect, start, sweep, true, Paint()..color = color);
    }

    arc(const Color(0xFF4285F4), -1.57, 3.14);
    arc(const Color(0xFFEA4335), -1.57, -1.57);
    arc(const Color(0xFFFBBC05), 1.57, 1.57);
    arc(const Color(0xFF34A853), 0, 1.57);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.34,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}
