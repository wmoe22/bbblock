import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppIcons {
  // Category icons
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Scam':
        return Icons.warning_rounded;
      case 'Telemarketing':
        return Icons.campaign_rounded;
      case 'Finance':
        return Icons.account_balance_rounded;
      case 'Fundraising':
        return Icons.volunteer_activism_rounded;
      case 'Services':
        return Icons.build_rounded;
      case 'Healthcare':
        return Icons.local_hospital_rounded;
      case 'Government':
        return Icons.account_balance_rounded;
      case 'Safe':
        return Icons.verified_user_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Category colors (theme-aware so they stay legible in light and dark)
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Scam':
        return AppTheme.accentRed;
      case 'Telemarketing':
        return AppTheme.accentOrange;
      case 'Finance':
        return AppTheme.primaryBlue;
      case 'Fundraising':
        return AppTheme.accentPurple;
      case 'Services':
        return AppTheme.primaryBlue;
      case 'Healthcare':
        return AppTheme.accentGreen;
      case 'Government':
        return const Color(0xFF1FA39A);
      case 'Safe':
        return AppTheme.accentGreen;
      default:
        return AppTheme.textMuted;
    }
  }

  // Threat level colors
  static Color getThreatColor(String level) {
    switch (level) {
      case 'High':
        return AppTheme.accentRed;
      case 'Medium':
        return AppTheme.accentOrange;
      case 'Low':
        return AppTheme.accentGreen;
      default:
        return AppTheme.accentGreen;
    }
  }
}
