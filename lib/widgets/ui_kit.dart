import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Layout constants
// ─────────────────────────────────────────────────────────────────────────────

class AppLayout {
  static const double pagePadding = 20;

  /// Bottom scroll inset so content clears the floating tab bar.
  static const double bottomInset = 128;
}

/// Haptics that never throw (missing plugin in tests, desktop, web).
class AppHaptics {
  static void selection() => _safe(HapticFeedback.selectionClick());
  static void medium() => _safe(HapticFeedback.mediumImpact());
  static void heavy() => _safe(HapticFeedback.heavyImpact());

  static void _safe(Future<void> f) {
    f.catchError((Object _) {});
  }
}

Color _shift(Color c, double deltaLightness) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withLightness((hsl.lightness + deltaLightness).clamp(0.0, 1.0))
      .toColor();
}

// ─────────────────────────────────────────────────────────────────────────────
// Motion
// ─────────────────────────────────────────────────────────────────────────────

extension AppAppear on Widget {
  /// Subtle staggered entrance used across the app.
  Widget appear({int index = 0, double dy = 0.04}) {
    return animate()
        .fadeIn(
          delay: Duration(milliseconds: 40 * index),
          duration: 420.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: dy,
          end: 0,
          delay: Duration(milliseconds: 40 * index),
          duration: 480.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Scales + dims its child on press, like native iOS controls.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: () {
          if (widget.haptic) AppHaptics.selection();
          widget.onTap!();
        },
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _down ? 0.88 : 1,
            duration: const Duration(milliseconds: 140),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Surfaces
// ─────────────────────────────────────────────────────────────────────────────

/// Continuous-corner ("squircle") card with hairline border and soft depth.
class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool elevated;

  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 22,
    this.color,
    this.gradient,
    this.borderColor,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? AppTheme.hairline, width: 0.8),
    );

    Widget content = DecoratedBox(
      decoration: ShapeDecoration(
        color: gradient == null ? (color ?? AppTheme.cardDark) : null,
        gradient: gradient,
        shape: shape,
        shadows: elevated ? AppTheme.cardShadows : null,
      ),
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );

    content = SizedBox(width: double.infinity, child: content);

    if (onTap != null) {
      content = PressableScale(scale: 0.985, onTap: onTap, child: content);
    }
    if (margin != null) content = Padding(padding: margin!, child: content);
    return content;
  }
}

/// iOS-style icon tile: gradient fill with white glyph, or a soft tint.
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool soft;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.3;
    final glyph = size * 0.54;

    if (soft) {
      return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: color.withValues(alpha: AppTheme.isDark ? 0.16 : 0.1),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Icon(icon, color: color, size: glyph),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_shift(color, 0.07), _shift(color, -0.08)],
        ),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        shadows: [
          BoxShadow(
            color: color.withValues(alpha: AppTheme.isDark ? 0.18 : 0.28),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: glyph),
    );
  }
}

/// Tinted capsule label.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool dot;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: AppFont.main(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Only flex when the parent gives a bounded width; a Flexible inside an
        // unbounded Row would throw.
        final bounded = constraints.maxWidth.isFinite;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: ShapeDecoration(
            color: color.withValues(alpha: AppTheme.isDark ? 0.16 : 0.1),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 5),
              ],
              if (bounded) Flexible(child: text) else text,
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controls
// ─────────────────────────────────────────────────────────────────────────────

enum AppButtonKind { primary, tinted, destructive, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final Color? color;
  final double height;
  final double fontSize;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.kind = AppButtonKind.primary,
    this.color,
    this.height = 50,
    this.fontSize = 16,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppTheme.primaryBlue;
    late final Color fg;
    BoxDecoration decoration;
    final radius = BorderRadius.circular(16);

    switch (kind) {
      case AppButtonKind.primary:
        fg = Colors.white;
        decoration = BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppTheme.primaryGradient,
          ),
          boxShadow: AppTheme.isDark
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        );
      case AppButtonKind.destructive:
        fg = Colors.white;
        decoration = BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _shift(AppTheme.accentRedFill, 0.04),
              _shift(AppTheme.accentRedFill, -0.05),
            ],
          ),
        );
      case AppButtonKind.tinted:
        fg = tint;
        decoration = BoxDecoration(
          borderRadius: radius,
          color: tint.withValues(alpha: AppTheme.isDark ? 0.16 : 0.1),
        );
      case AppButtonKind.outlined:
        fg = tint;
        decoration = BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: tint.withValues(alpha: 0.45), width: 1.2),
        );
    }

    final enabled = onPressed != null;

    Widget button = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: decoration,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 3, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                maxLines: 1,
                style: AppFont.main(
                  color: fg,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expand) button = SizedBox(width: double.infinity, child: button);

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: PressableScale(
        onTap: onPressed,
        haptic: true,
        scale: 0.96,
        child: button,
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: (v) {
        AppHaptics.selection();
        onChanged(v);
      },
      activeTrackColor: AppTheme.isDark
          ? const Color(0xFF3D70E6)
          : AppTheme.primaryBlue,
      inactiveTrackColor: AppTheme.isDark
          ? const Color(0xFF2A3558)
          : const Color(0xFFD3D9E8),
      thumbColor: Colors.white,
    );
  }
}

class AppSegment {
  final String label;
  final int? badge;
  const AppSegment(this.label, {this.badge});
}

/// iOS segmented control with a sliding thumb.
class AppSegmentedControl extends StatelessWidget {
  final List<AppSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;
    final track = isDark ? const Color(0xFF162040) : const Color(0xFFE6EAF4);
    final thumb = isDark ? const Color(0xFF2B3B70) : Colors.white;
    const inset = 3.0;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(inset),
      decoration: ShapeDecoration(
        color: track,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segWidth = constraints.maxWidth / segments.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: segWidth * selectedIndex,
                top: 0,
                bottom: 0,
                width: segWidth,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: thumb,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.4 : 0.1,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < segments.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i != selectedIndex) {
                            AppHaptics.selection();
                            onChanged(i);
                          }
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: AppFont.main(
                                    fontSize: 13.5,
                                    letterSpacing: -0.2,
                                    fontWeight: i == selectedIndex
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: i == selectedIndex
                                        ? AppTheme.textPrimary
                                        : AppTheme.textSecondary,
                                  ),
                                  child: Text(
                                    segments[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if ((segments[i].badge ?? 0) > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${segments[i].badge}',
                                    style: AppFont.main(
                                      color: AppTheme.onAccentOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grouped lists
// ─────────────────────────────────────────────────────────────────────────────

class AppHairline extends StatelessWidget {
  final double indent;
  const AppHairline({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(height: 0.6, color: AppTheme.hairline),
    );
  }
}

/// Inset-grouped section: small caps label, rounded card, optional footer.
class GroupedSection extends StatelessWidget {
  final String? title;
  final String? footer;
  final List<Widget> children;
  final double dividerIndent;

  const GroupedSection({
    super.key,
    this.title,
    this.footer,
    required this.children,
    this.dividerIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(AppHairline(indent: dividerIndent));
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              title!.toUpperCase(),
              style: AppFont.main(
                color: AppTheme.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        AppSurface(
          padding: EdgeInsets.zero,
          radius: 20,
          child: Column(children: rows),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              footer!,
              style: AppFont.sub(
                color: AppTheme.textMuted,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

/// A single row inside a [GroupedSection].
class AppRow extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const AppRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  @override
  State<AppRow> createState() => _AppRowState();
}

class _AppRowState extends State<AppRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final row = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      color: _down ? AppTheme.hairline : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppFont.main(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppFont.sub(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 12),
            widget.trailing!,
          ],
          if (widget.showChevron) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppTheme.textMuted.withValues(alpha: 0.7),
            ),
          ],
        ],
      ),
    );

    if (widget.onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: row,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppFont.main(
              color: AppTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (actionLabel != null)
          PressableScale(
            onTap: onAction,
            scale: 0.94,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                actionLabel!,
                style: AppFont.main(
                  color: AppTheme.primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconBadge(
              icon: icon,
              color: color ?? AppTheme.primaryBlue,
              size: 76,
              soft: true,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFont.main(
                color: AppTheme.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFont.sub(
                color: AppTheme.textSecondary,
                fontSize: 15,
                height: 1.4,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    ).appear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Risk gauge
// ─────────────────────────────────────────────────────────────────────────────

class RiskGauge extends StatelessWidget {
  final int score;
  final Color color;
  final double size;

  const RiskGauge({
    super.key,
    required this.score,
    required this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (score / 100).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(value: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score%',
                    style: AppFont.main(
                      color: AppTheme.textPrimary,
                      fontSize: size * 0.27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: size * 0.04),
                  Text(
                    'RISK',
                    style: AppFont.main(
                      color: AppTheme.textMuted,
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  const _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: 0.16);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Large-title header (collapses into a blurred inline title)
// ─────────────────────────────────────────────────────────────────────────────

/// Gives screens access to shell-level actions (the threat simulator).
class ShellScope extends InheritedWidget {
  final VoidCallback onSimulate;

  const ShellScope({super.key, required this.onSimulate, required super.child});

  static ShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope old) => false;
}

class LargeTitleSliver extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const LargeTitleSliver({
    super.key,
    required this.title,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _LargeTitleDelegate(top: top, title: title, actions: actions),
    );
  }
}

class _LargeTitleDelegate extends SliverPersistentHeaderDelegate {
  final double top;
  final String title;
  final List<Widget> actions;

  static const double _bar = 52;
  static const double _large = 58;

  _LargeTitleDelegate({
    required this.top,
    required this.title,
    required this.actions,
  });

  @override
  double get minExtent => top + _bar;

  @override
  double get maxExtent => top + _bar + _large;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / _large).clamp(0.0, 1.0);
    final bg = AppTheme.darkBackground;

    final actionRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          actions[i],
        ],
      ],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (t > 0.02)
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bg.withValues(alpha: 0.78 * t),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.hairline.withValues(
                        alpha: AppTheme.hairline.a * t,
                      ),
                      width: 0.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: top,
          left: 0,
          right: 0,
          height: _bar,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: t,
                child: Text(
                  title,
                  style: AppFont.main(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: actionRow,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppLayout.pagePadding,
          right: AppLayout.pagePadding,
          bottom: 6,
          child: Opacity(
            opacity: (1 - t * 1.7).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 1 - 0.05 * t,
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.main(
                  color: AppTheme.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _LargeTitleDelegate old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheets & toasts
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.cardDark,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 38,
          height: 5,
          decoration: BoxDecoration(
            color: AppTheme.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Flexible(child: builder(ctx)),
      ],
    ),
  );
}

void showAppSnack(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppFont.sub(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppTheme.snackBarAction,
              onPressed: onAction ?? () {},
            )
          : null,
    ),
  );
}
