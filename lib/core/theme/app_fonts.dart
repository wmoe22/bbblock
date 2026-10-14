import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography pairing.
///
/// * [main] → **Inter**: titles, headings, labels, numbers, buttons, pills.
/// * [sub]  → **Geist**: body copy, subtitles, captions, metadata, hints.
///
/// Both mirror [TextStyle]'s named parameters. Always build styles through
/// these helpers (not a bare `TextStyle(fontWeight: …)`): `google_fonts` ships
/// one font file per weight, so the weight must be resolved here for the
/// correct file to load instead of a synthesized faux-bold.
class AppFont {
  const AppFont._();

  static TextStyle main({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
  }) => GoogleFonts.inter(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
    fontFeatures: fontFeatures,
    decoration: decoration,
  );

  static TextStyle sub({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
  }) => GoogleFonts.geist(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
    fontFeatures: fontFeatures,
    decoration: decoration,
  );

  /// Family name for the main font's regular weight (for `ThemeData.fontFamily`).
  static String? get mainFamily => GoogleFonts.inter().fontFamily;

  /// Family name for the sub font's regular weight.
  static String? get subFamily => GoogleFonts.geist().fontFamily;
}
