import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/call_provider.dart';
import '../../providers/sms_provider.dart';
import '../../widgets/protection_shield.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/recent_call_tile.dart';
import '../../widgets/category_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CallProvider, SmsProvider>(
      builder: (context, callProvider, smsProvider, _) {
        if (callProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Protection Shield
              const ProtectionShield()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.block_rounded,
                      label: 'Blocked Today',
                      value: '${callProvider.totalBlockedToday}',
                      color: AppTheme.accentRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.visibility_rounded,
                      label: 'Identified',
                      value: '${callProvider.totalIdentifiedToday}',
                      color: AppTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.sms_rounded,
                      label: 'SMS Threats',
                      value: '${smsProvider.unreadThreats}',
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Auto-Block Controls
              _buildSectionHeader(context, 'Auto-Block', Icons.shield_rounded),
              const SizedBox(height: 12),
              _buildAutoBlockCard(context, callProvider)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Category Breakdown
              _buildSectionHeader(
                  context, 'Blocked by Category', Icons.pie_chart_rounded),
              const SizedBox(height: 12),
              _buildCategoryBreakdown(callProvider)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Recent Activity
              _buildSectionHeader(
                  context, 'Recent Activity', Icons.history_rounded),
              const SizedBox(height: 12),
              ...callProvider.recentCalls.asMap().entries.map((entry) {
                return RecentCallTile(call: entry.value)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 450 + entry.key * 50),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.05, end: 0);
              }),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildAutoBlockCard(BuildContext context, CallProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            context,
            icon: Icons.warning_rounded,
            iconColor: AppTheme.accentRed,
            title: 'Block Scam Calls',
            subtitle: 'Automatically block known scam numbers',
            value: provider.autoBlockScam,
            onChanged: provider.toggleAutoBlockScam,
          ),
          Divider(color: AppTheme.dividerColor, height: 1, indent: 56),
          _buildToggleRow(
            context,
            icon: Icons.campaign_rounded,
            iconColor: AppTheme.accentOrange,
            title: 'Block Telemarketing',
            subtitle: 'Automatically block telemarketing calls',
            value: provider.autoBlockTelemarketing,
            onChanged: provider.toggleAutoBlockTelemarketing,
          ),
          Divider(color: AppTheme.dividerColor, height: 1, indent: 56),
          _buildToggleRow(
            context,
            icon: Icons.phone_callback_rounded,
            iconColor: AppTheme.primaryBlue,
            title: 'Call Screening',
            subtitle: 'Show caller ID for incoming calls',
            value: provider.callScreeningEnabled,
            onChanged: provider.toggleCallScreening,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 14)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(CallProvider provider) {
    final breakdown = provider.categoryBreakdown;
    if (breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text('No blocked calls yet',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: breakdown.entries.map((entry) {
        return CategoryChip(
          category: entry.key,
          count: entry.value,
          color: AppIcons.getCategoryColor(entry.key),
          icon: AppIcons.getCategoryIcon(entry.key),
        );
      }).toList(),
    );
  }
}
