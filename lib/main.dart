import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'core/theme/app_appearance.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/appearance_rebuilder.dart';
import 'providers/call_provider.dart';
import 'providers/sms_provider.dart';
import 'providers/fraud_guard_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppAppearance.instance.load();
  AppTheme.applySystemUiStyle();
  runApp(const HangUpApp());
}

/// Smooth, platform-independent bouncing scroll physics for an iOS feel.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class HangUpApp extends StatelessWidget {
  const HangUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CallProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => SmsProvider()..loadMessages()),
        ChangeNotifierProvider(create: (_) => FraudGuardProvider()..loadData()),
      ],
      child: AnimatedBuilder(
        animation: AppAppearance.instance,
        builder: (context, _) {
          AppTheme.applySystemUiStyle();
          return MaterialApp(
            title: 'BBBlock',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const _AppScrollBehavior(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppAppearance.instance.isDark
                ? ThemeMode.dark
                : ThemeMode.light,
            themeAnimationDuration: const Duration(milliseconds: 350),
            themeAnimationCurve: Curves.easeOutCubic,
            builder: (context, child) =>
                AppearanceRebuilder(child: child ?? const SizedBox.shrink()),
            home: const AppEntry(),
          );
        },
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showOnboarding
          ? OnboardingScreen(
              key: const ValueKey('onboarding'),
              onComplete: () => setState(() => _showOnboarding = false),
            )
          : const MainShell(key: ValueKey('shell')),
    );
  }
}
