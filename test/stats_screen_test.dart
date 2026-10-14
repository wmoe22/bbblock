import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hangup_clone/core/theme/app_theme.dart';
import 'package:hangup_clone/providers/call_provider.dart';
import 'package:hangup_clone/providers/sms_provider.dart';
import 'package:hangup_clone/screens/stats/stats_screen.dart';

void main() {
  testWidgets('StatsScreen renders and switches periods without errors', (WidgetTester tester) async {
    final callProvider = CallProvider();
    final smsProvider = SmsProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: callProvider),
          ChangeNotifierProvider.value(value: smsProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: StatsScreen()),
        ),
      ),
    );

    callProvider.loadData();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(StatsScreen), findsOneWidget);

    // Switch to Month
    await tester.tap(find.text('Month'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Month'), findsOneWidget);

    // Switch to Year
    await tester.tap(find.text('Year'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Year'), findsOneWidget);

    // Switch back to Week
    await tester.tap(find.text('Week'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Week'), findsOneWidget);
  });
}
