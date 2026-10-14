import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hangup_clone/core/theme/app_theme.dart';
import 'package:hangup_clone/providers/fraud_guard_provider.dart';
import 'package:hangup_clone/screens/escalations/ai_escalations_screen.dart';

void main() {
  testWidgets('AiEscalationsScreen renders pending items and resolves them', (
    WidgetTester tester,
  ) async {
    final fraudProvider = FraudGuardProvider();
    await fraudProvider.loadData();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: fraudProvider,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: AiEscalationsScreen()),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AiEscalationsScreen), findsOneWidget);
    expect(find.text('Pending Decision'), findsOneWidget);
    expect(find.text('Block & Sync'), findsWidgets);
    expect(find.text('Allow & Whitelist'), findsWidgets);

    final initialCount = fraudProvider.pendingEscalationsCount;

    // Tap the first "Block & Sync" button (scroll it into view first)
    await tester.ensureVisible(find.text('Block & Sync').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Block & Sync').first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Pending count must have decreased by 1
    expect(fraudProvider.pendingEscalationsCount, equals(initialCount - 1));

    // Switch to Resolved tab
    await tester.tap(find.textContaining('Resolved'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Blocked by owner & synced to Pipedream'), findsOneWidget);
  });
}
