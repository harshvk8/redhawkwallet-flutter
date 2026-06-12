import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:redhawkwallet_flutter/main.dart';

void main() {
  Future<void> openRouteAndReturn(
    WidgetTester tester,
    String actionLabel,
    String expectedTitle,
  ) async {
    await tester.tap(find.widgetWithText(ElevatedButton, actionLabel));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(expectedTitle),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Student Dashboard'),
      ),
      findsOneWidget,
    );
  }

  testWidgets('dashboard routes push and pop correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Student Dashboard'), findsOneWidget);

    await openRouteAndReturn(tester, 'My QR', 'My QR Code');
    await openRouteAndReturn(tester, 'Scan', 'Scan QR Code');
    await openRouteAndReturn(tester, 'Transactions', 'Transaction History');

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Account Profile'),
      ),
      findsOneWidget,
    );

    final verificationButton = find.widgetWithText(
      FilledButton,
      'Open University Verification',
    );
    await tester.ensureVisible(verificationButton);
    await tester.tap(verificationButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('University Verification'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Account Profile'),
      ),
      findsOneWidget,
    );

    final logoutButton = find.widgetWithText(OutlinedButton, 'Logout');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Login')),
      findsOneWidget,
    );

    final signInButton = find.widgetWithText(FilledButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Student Dashboard'),
      ),
      findsOneWidget,
    );
  });
}
