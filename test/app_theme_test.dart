import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hangup_clone/core/theme/app_appearance.dart';
import 'package:hangup_clone/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'appearance changes the palette and persists the selected mode',
    () async {
      await AppAppearance.instance.setMode(AppAppearanceMode.light);

      // Light mode: white surfaces with deep navy accents.
      expect(AppTheme.isDark, isFalse);
      expect(AppTheme.darkBackground, const Color(0xFFF4F6FB));
      expect(AppTheme.cardDark, const Color(0xFFFFFFFF));
      expect(AppTheme.primaryBlue, const Color(0xFF0A2F7A));
      expect(AppTheme.primaryBlueDeep, const Color(0xFF061A4D));
      expect(AppTheme.textPrimary, const Color(0xFF0A1A3C));
      // Inter is the main font (titles, labels); Geist is the sub font (body).
      expect(
        AppTheme.lightTheme.textTheme.titleMedium?.fontFamily,
        startsWith('Inter'),
      );
      expect(
        AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
        startsWith('Geist'),
      );

      await AppAppearance.instance.setMode(AppAppearanceMode.dark);

      // Dark mode: blue-black ink canvas with midnight-navy surfaces.
      expect(AppTheme.isDark, isTrue);
      expect(AppTheme.darkBackground, const Color(0xFF0A1020));
      expect(AppTheme.cardDark, const Color(0xFF121A30));
      expect(AppTheme.primaryBlue, const Color(0xFF5B8DF6));
      expect(AppTheme.primaryBlueDeep, const Color(0xFF153585));
      expect(AppTheme.textPrimary, const Color(0xFFF5F7FF));

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('app_appearance_mode'), 'dark');
    },
  );
}
