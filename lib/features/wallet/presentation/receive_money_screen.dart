import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceiveMoneyScreen extends StatelessWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final walletId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Receive Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B1A2E), Color(0xFFC8102E)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share your wallet ID or QR', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 13)),
                  SizedBox(height: 6),
                  Text('Get paid in seconds', style: TextStyle(color: colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('This QR is a UI-only demo placeholder.', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _qrPreview(colorScheme, walletId),
                  const SizedBox(height: 16),
                  Text('Wallet ID', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(walletId, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: walletId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet ID copied')));
                            }
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy ID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share action is demo-only')));
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B1A2E),
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How students can pay you', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('1. Open the wallet app', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  Text('2. Scan this QR or copy the wallet ID', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  Text('3. Confirm the transfer', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrPreview(ColorScheme colorScheme, String walletId) {
    final pattern = _buildQrPattern(walletId);
    const size = 21;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: size * size,
            itemBuilder: (context, index) {
              final row = index ~/ size;
              final col = index % size;
              final cell = pattern[row][col];

              if (cell == 2) {
                return _finderModule(colorScheme.primary, colorScheme);
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: cell == 1 ? colorScheme.onSurface : colorScheme.surface,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<List<int>> _buildQrPattern(String walletId) {
    const size = 21;
    final pattern = List.generate(size, (_) => List<int>.filled(size, 0));

    void setFinder(int startRow, int startCol) {
      for (var row = 0; row < 7; row++) {
        for (var col = 0; col < 7; col++) {
          final absRow = startRow + row;
          final absCol = startCol + col;
          final isBorder = row == 0 || row == 6 || col == 0 || col == 6;
          final isCenter = row >= 2 && row <= 4 && col >= 2 && col <= 4;
          if (isBorder || isCenter) {
            pattern[absRow][absCol] = 2;
          }
        }
      }
    }

    setFinder(0, 0);
    setFinder(0, size - 7);
    setFinder(size - 7, 0);

    for (var i = 0; i < size; i++) {
      if (pattern[6][i] == 0) {
        pattern[6][i] = i.isEven ? 1 : 0;
      }
      if (pattern[i][6] == 0) {
        pattern[i][6] = i.isOdd ? 1 : 0;
      }
    }

    final seed = walletId.codeUnits;
    var seedIndex = 0;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (pattern[row][col] != 0) {
          continue;
        }
        final value = seed[seedIndex % seed.length];
        pattern[row][col] = ((value + row * 7 + col * 13 + seedIndex) % 5 == 0) ? 1 : 0;
        seedIndex++;
      }
    }

    return pattern;
  }

  Widget _finderModule(Color color, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1.5),
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