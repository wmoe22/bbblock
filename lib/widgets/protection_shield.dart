import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/call_provider.dart';

class ProtectionShield extends StatelessWidget {
  const ProtectionShield({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CallProvider>();
    final isActive = provider.callScreeningEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  AppTheme.primaryBlue.withValues(alpha: 0.2),
                  AppTheme.accentGreen.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.accentRed.withValues(alpha: 0.2),
                  AppTheme.accentOrange.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.accentGreen.withValues(alpha: 0.3)
              : AppTheme.accentRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Shield icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isActive ? AppTheme.accentGreen : AppTheme.accentRed)
                  .withValues(alpha: 0.15),
              border: Border.all(
                color: (isActive ? AppTheme.accentGreen : AppTheme.accentRed)
                    .withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(
              isActive ? Icons.shield_rounded : Icons.shield_outlined,
              color: isActive ? AppTheme.accentGreen : AppTheme.accentRed,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // Status text
          Text(
            isActive ? 'Protection Active' : 'Protection Disabled',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isActive ? AppTheme.accentGreen : AppTheme.accentRed,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            isActive
                ? 'Your phone is protected from spam and scam calls'
                : 'Enable call screening to protect your phone',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Stats summary
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStat(
                context,
                icon: Icons.block_rounded,
                value: '${provider.blockedCalls.length}',
                label: 'Blocked',
              ),
              Container(
                height: 30,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: AppTheme.dividerColor,
              ),
              _buildMiniStat(
                context,
                icon: Icons.verified_user_rounded,
                value: '${provider.callHistory.length}',
                label: 'Screened',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context,
      {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
