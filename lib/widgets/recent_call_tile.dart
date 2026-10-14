import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_icons.dart';
import '../models/call_record.dart';
import '../providers/call_provider.dart';

class RecentCallTile extends StatelessWidget {
  final CallRecord call;

  const RecentCallTile({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final color = AppIcons.getCategoryColor(call.category);
    final icon = AppIcons.getCategoryIcon(call.category);
    final provider = context.read<CallProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: call.wasBlocked
              ? AppTheme.accentRed.withValues(alpha: 0.2)
              : AppTheme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Call info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        call.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        call.category,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      call.wasBlocked
                          ? Icons.block_rounded
                          : call.isIncoming
                              ? Icons.call_received_rounded
                              : Icons.call_made_rounded,
                      color: call.wasBlocked
                          ? AppTheme.accentRed
                          : AppTheme.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      call.wasBlocked ? 'Blocked' : call.formattedTime,
                      style: TextStyle(
                        color: call.wasBlocked
                            ? AppTheme.accentRed
                            : AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      call.formattedDate,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    if (call.contactName != null) ...[
                      const Spacer(),
                      Text(
                        call.phoneNumber,
                        style:
                            TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Block/Unblock button
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (provider.isNumberBlocked(call.phoneNumber)) {
                provider.unblockNumber(call.phoneNumber);
              } else {
                provider.blockNumber(call.phoneNumber);
              }
            },
            child: Icon(
              provider.isNumberBlocked(call.phoneNumber)
                  ? Icons.block_rounded
                  : Icons.more_vert_rounded,
              color: provider.isNumberBlocked(call.phoneNumber)
                  ? AppTheme.accentRed
                  : AppTheme.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
