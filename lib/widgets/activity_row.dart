import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/ai_threat_record.dart';
import '../models/channel_type.dart';
import 'ui_kit.dart';

Color decisionColor(ThreatDecision decision) {
  if (decision.isBlocked) return AppTheme.accentRed;
  if (decision == ThreatDecision.escalatedToUser) return AppTheme.accentOrange;
  return AppTheme.accentGreen;
}

IconData decisionIcon(ThreatDecision decision) {
  if (decision.isBlocked) return Icons.block_rounded;
  if (decision == ThreatDecision.escalatedToUser) {
    return Icons.psychology_alt_rounded;
  }
  return Icons.check_circle_rounded;
}

/// Short pill label that always fits on one line.
String decisionShortLabel(ThreatDecision decision) {
  if (decision.isBlocked) return 'Blocked';
  if (decision == ThreatDecision.escalatedToUser) return 'Review';
  return 'Allowed';
}

String senderTitle(AiThreatRecord record) {
  final name = record.senderDisplayName;
  return (name != null && name.isNotEmpty) ? name : record.senderHandle;
}

/// A single activity entry, designed to live inside a [GroupedSection].
class ActivityRow extends StatefulWidget {
  final AiThreatRecord record;
  final VoidCallback? onTap;
  final bool showDate;

  const ActivityRow({
    super.key,
    required this.record,
    this.onTap,
    this.showDate = false,
  });

  @override
  State<ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<ActivityRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final channel = record.channel;
    final color = decisionColor(record.decision);
    final time = widget.showDate && record.formattedDate != 'Today'
        ? record.formattedDate
        : record.formattedTime;

    final row = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      color: _down ? AppTheme.hairline : Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(icon: channel.icon, color: channel.color, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        senderTitle(record),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.main(
                          color: AppTheme.textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: AppFont.sub(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  record.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.sub(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Short label + fixed width: the pill never clips or squishes.
                    StatusPill(
                      label: decisionShortLabel(record.decision),
                      color: color,
                      icon: decisionIcon(record.decision),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        record.threatCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.sub(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${record.riskScore}% risk',
                      maxLines: 1,
                      style: AppFont.main(
                        color: color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
