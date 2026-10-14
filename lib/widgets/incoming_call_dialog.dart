import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_icons.dart';
import '../models/call_record.dart';
import '../providers/call_provider.dart';
import 'ui_kit.dart';

class IncomingCallDialog extends StatelessWidget {
  final CallRecord call;

  const IncomingCallDialog({super.key, required this.call});

  static Future<void> show(BuildContext context, CallRecord call) {
    AppHaptics.heavy();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Incoming call',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, _, _) => IncomingCallDialog(call: call),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppIcons.getCategoryColor(call.category);
    final categoryIcon = AppIcons.getCategoryIcon(call.category);
    final callProvider = context.read<CallProvider>();
    final tone = call.wasBlocked ? AppTheme.accentRed : categoryColor;
    final toneFill = call.wasBlocked ? AppTheme.accentRedFill : categoryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AppSurface(
        radius: 36,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        color: AppTheme.cardDark,
        borderColor: tone.withValues(alpha: 0.35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusPill(
              label: 'BBBlock Caller ID',
              color: AppTheme.primaryBlue,
              icon: Icons.shield_rounded,
            ),
            const SizedBox(height: 26),

            SizedBox(
              width: 128,
              height: 128,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: toneFill.withValues(alpha: 0.16),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.9, end: 1.14, duration: 1100.ms),
                  AppIconBadge(icon: categoryIcon, color: toneFill, size: 84),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Text(
              call.displayName,
              textAlign: TextAlign.center,
              style: AppFont.main(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              call.phoneNumber,
              style: AppFont.sub(
                color: AppTheme.textSecondary,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 14),

            StatusPill(
              label: call.wasBlocked
                  ? 'Auto-blocked · ${call.category}'
                  : '${call.category} identified',
              color: tone,
              icon: call.wasBlocked ? Icons.block_rounded : categoryIcon,
            ),

            const SizedBox(height: 22),

            GroupedSection(
              children: [
                AppRow(
                  title: 'Threat level',
                  trailing: Text(
                    call.threatLevel,
                    style: AppFont.main(
                      color: AppIcons.getThreatColor(call.threatLevel),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppRow(
                  title: 'Action taken',
                  trailing: Text(
                    call.wasBlocked ? 'Blocked' : 'Screened',
                    style: AppFont.main(
                      color: call.wasBlocked
                          ? AppTheme.accentRed
                          : AppTheme.accentGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            if (call.wasBlocked)
              AppButton(
                label: 'Dismiss',
                icon: Icons.check_rounded,
                kind: AppButtonKind.tinted,
                onPressed: () => Navigator.pop(context),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Block',
                      icon: Icons.block_rounded,
                      kind: AppButtonKind.destructive,
                      onPressed: () {
                        callProvider.blockNumber(call.phoneNumber);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Decline',
                      icon: Icons.call_end_rounded,
                      kind: AppButtonKind.tinted,
                      color: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
