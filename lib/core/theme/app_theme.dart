import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_appearance.dart';
import 'app_fonts.dart';

export 'app_fonts.dart';

/// BBBlock design system.
///
/// Light mode: crisp white surfaces, deep navy ink and accents.
/// Dark mode: blue-black ink canvas with midnight-navy surfaces and a luminous blue.
///
/// All existing getter names are preserved so legacy call sites keep working;
/// new tokens (hairline, gradients, shadows, glass) are additive.
class AppTheme {
  // ── Brand blues ──────────────────────────────────────────────────────────
  static const Color _blueLight = Color(0xFF0A2F7A); // navy
  static const Color _blueLightDeep = Color(0xFF061A4D); // midnight
  static const Color _blueDark = Color(
    0xFF5B8DF6,
  ); // luminous (text/icon on black)
  static const Color _blueDarkDeep = Color(0xFF153585); // deep fill

  // ── Light neutrals ───────────────────────────────────────────────────────
  static const Color _lightBackground = Color(0xFFF4F6FB);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightCardRaised = Color(0xFFF0F3FA);
  static const Color _lightSurface = Color(0xFFEBEFF8);
  static const Color _lightTextPrimary = Color(0xFF0A1A3C);
  static const Color _lightTextSecondary = Color(0xFF4F5B7A);
  static const Color _lightTextMuted = Color(0xFF6B7795);
  static const Color _lightDivider = Color(0xFFDDE3EF);

  // ── Dark neutrals ────────────────────────────────────────────────────────
  static const Color _darkBackground = Color(0xFF0A1020); // blue-black ink
  static const Color _darkCard = Color(0xFF121A30);
  static const Color _darkCardRaised = Color(0xFF1A2442);
  static const Color _darkSurface = Color(0xFF0D1527);
  static const Color _darkTextPrimary = Color(0xFFF5F7FF);
  static const Color _darkTextSecondary = Color(0xFFA6B1CE);
  static const Color _darkTextMuted = Color(0xFF7783A2);
  static const Color _darkDivider = Color(0xFF222D52);

  static bool get isDark => AppAppearance.instance.isDark;

  // ── Brand ────────────────────────────────────────────────────────────────
  static Color get primaryBlue => isDark ? _blueDark : _blueLight;
  static Color get primaryBlueDeep => isDark ? _blueDarkDeep : _blueLightDeep;
  static Color get onPrimary => Colors.white;
  static Color get onError => Colors.white;

  /// Rich navy gradient used for hero surfaces and primary buttons.
  static List<Color> get primaryGradient => isDark
      ? const [Color(0xFF2F62D8), Color(0xFF153585)]
      : const [Color(0xFF14419E), Color(0xFF061A4D)];

  /// Deep "midnight" gradient for hero cards.
  static List<Color> get heroGradient => isDark
      ? const [Color(0xFF1A3270), Color(0xFF0A1530)]
      : const [Color(0xFF0F3A94), Color(0xFF051640)];

  // ── Snackbar ─────────────────────────────────────────────────────────────
  static Color get snackBarBackground =>
      isDark ? const Color(0xFF1A2342) : _lightTextPrimary;
  static Color get snackBarText => Colors.white;
  static Color get snackBarAction =>
      isDark ? const Color(0xFF8FB2FF) : const Color(0xFF9DBBFF);

  static Color foregroundFor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : const Color(0xFF0A1A3C);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static Color get darkBackground =>
      isDark ? _darkBackground : _lightBackground;
  static Color get cardDark => isDark ? _darkCard : _lightCard;
  static Color get cardDarkLighter =>
      isDark ? _darkCardRaised : _lightCardRaised;
  static Color get surfaceDark => isDark ? _darkSurface : _lightSurface;

  /// Translucent surface for floating glass chrome (tab bar, headers).
  static Color get glass => isDark
      ? _darkCard.withValues(alpha: 0.74)
      : Colors.white.withValues(alpha: 0.78);

  // ── Text ─────────────────────────────────────────────────────────────────
  static Color get textPrimary => isDark ? _darkTextPrimary : _lightTextPrimary;
  static Color get textSecondary =>
      isDark ? _darkTextSecondary : _lightTextSecondary;
  static Color get textMuted => isDark ? _darkTextMuted : _lightTextMuted;

  // ── Lines & depth ────────────────────────────────────────────────────────
  static Color get dividerColor => isDark ? _darkDivider : _lightDivider;
  static Color get hairline => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF0A1A3C).withValues(alpha: 0.07);

  static List<BoxShadow> get cardShadows => isDark
      ? const []
      : [
          BoxShadow(
            color: const Color(0xFF0A1A3C).withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: const Color(0xFF0A1A3C).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ];

  // ── Semantic accents ─────────────────────────────────────────────────────
  static Color get accentGreen =>
      isDark ? const Color(0xFF34D17F) : const Color(0xFF12874A);
  static Color get accentGreenFill =>
      isDark ? const Color(0xFF28B96C) : const Color(0xFF12874A);
  static Color get accentRed =>
      isDark ? const Color(0xFFFF5C6E) : const Color(0xFFD0213D);
  static Color get accentRedFill =>
      isDark ? const Color(0xFFE5384D) : const Color(0xFFD0213D);
  static Color get accentOrange =>
      isDark ? const Color(0xFFFFB03B) : const Color(0xFFB96A00);
  static Color get onAccentOrange =>
      isDark ? const Color(0xFF1A1000) : Colors.white;
  static Color get accentPurple =>
      isDark ? const Color(0xFF9C8CFF) : const Color(0xFF5A4BD8);

  static ThemeData get lightTheme => _buildTheme(isDark: false);
  static ThemeData get darkTheme => _buildTheme(isDark: true);

  /// Main font (Inter): titles, labels, buttons.
  static TextStyle _inter(
    double size,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
    double height = 1.3,
  }) => AppFont.main(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// Sub font (Geist): body copy, captions, hints.
  static TextStyle _geist(
    double size,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
    double height = 1.4,
  }) => AppFont.sub(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static ThemeData _buildTheme({required bool isDark}) {
    final background = isDark ? _darkBackground : _lightBackground;
    final card = isDark ? _darkCard : _lightCard;
    final raisedCard = isDark ? _darkCardRaised : _lightCardRaised;
    final surface = isDark ? _darkSurface : _lightSurface;
    final primaryText = isDark ? _darkTextPrimary : _lightTextPrimary;
    final secondaryText = isDark ? _darkTextSecondary : _lightTextSecondary;
    final mutedText = isDark ? _darkTextMuted : _lightTextMuted;
    final divider = isDark ? _darkDivider : _lightDivider;
    final blue = isDark ? _blueDark : _blueLight;
    final green = isDark ? const Color(0xFF34D17F) : const Color(0xFF12874A);
    final error = isDark ? const Color(0xFFFF5C6E) : const Color(0xFFD0213D);
    final snackBackground = isDark
        ? const Color(0xFF1A2342)
        : _lightTextPrimary;

    final textTheme = TextTheme(
      displayLarge: _inter(
        40,
        FontWeight.w800,
        primaryText,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: _inter(
        34,
        FontWeight.w700,
        primaryText,
        letterSpacing: -0.9,
        height: 1.12,
      ),
      displaySmall: _inter(
        30,
        FontWeight.w700,
        primaryText,
        letterSpacing: -0.7,
        height: 1.15,
      ),
      headlineLarge: _inter(
        30,
        FontWeight.w700,
        primaryText,
        letterSpacing: -0.7,
        height: 1.15,
      ),
      headlineMedium: _inter(
        28,
        FontWeight.w700,
        primaryText,
        letterSpacing: -0.6,
        height: 1.18,
      ),
      headlineSmall: _inter(
        24,
        FontWeight.w700,
        primaryText,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      titleLarge: _inter(
        20,
        FontWeight.w700,
        primaryText,
        letterSpacing: -0.4,
        height: 1.25,
      ),
      titleMedium: _inter(
        16,
        FontWeight.w600,
        primaryText,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      titleSmall: _inter(
        14,
        FontWeight.w600,
        primaryText,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      bodyLarge: _geist(
        17,
        FontWeight.w400,
        primaryText,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      bodyMedium: _geist(
        15,
        FontWeight.w400,
        secondaryText,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      bodySmall: _geist(
        13,
        FontWeight.w400,
        mutedText,
        letterSpacing: -0.1,
        height: 1.35,
      ),
      labelLarge: _inter(15, FontWeight.w600, primaryText, letterSpacing: -0.2),
      labelMedium: _inter(12, FontWeight.w600, secondaryText, letterSpacing: 0),
      labelSmall: _inter(11, FontWeight.w600, mutedText, letterSpacing: 0.2),
    );

    final colorScheme =
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
              primary: blue,
              onPrimary: Colors.white,
              secondary: green,
              onSecondary: isDark ? _darkBackground : Colors.white,
              surface: card,
              onSurface: primaryText,
              surfaceContainerHighest: raisedCard,
              error: error,
              onError: Colors.white,
              outline: mutedText,
              outlineVariant: divider,
            );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: AppFont.mainFamily,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: blue.withValues(alpha: 0.04),
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : _lightTextPrimary.withValues(alpha: 0.07),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _inter(
          17,
          FontWeight.w600,
          primaryText,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: blue),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: blue,
        unselectedItemColor: mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 50),
          textStyle: _inter(
            16,
            FontWeight.w600,
            Colors.white,
            letterSpacing: -0.2,
          ),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: blue,
          minimumSize: const Size(0, 50),
          side: BorderSide(color: divider),
          textStyle: _inter(16, FontWeight.w600, blue, letterSpacing: -0.2),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: blue,
          textStyle: _inter(15, FontWeight.w600, blue, letterSpacing: -0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raisedCard,
        hintStyle: _geist(15, FontWeight.w400, mutedText, letterSpacing: -0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: blue.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? const Color(0xFF3D70E6) : _blueLight;
          }
          return isDark ? const Color(0xFF2A3558) : const Color(0xFFD3D9E8);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: blue,
        inactiveTrackColor: isDark
            ? const Color(0xFF1F2A4D)
            : const Color(0xFFDCE2EF),
        thumbColor: Colors.white,
        overlayColor: blue.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 11,
          elevation: 3,
          pressedElevation: 5,
        ),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : _lightTextPrimary.withValues(alpha: 0.07),
        thickness: 0.6,
        space: 0.6,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: card,
        modalBarrierColor: Colors.black.withValues(alpha: isDark ? 0.6 : 0.35),
        showDragHandle: false,
        shape: RoundedSuperellipseBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBackground,
        contentTextStyle: _geist(
          14,
          FontWeight.w500,
          Colors.white,
          letterSpacing: -0.2,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: ShapeDecoration(
          color: snackBackground,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textStyle: _geist(12, FontWeight.w500, Colors.white),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: blue),
    );
  }

  static void applySystemUiStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: darkBackground,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}
