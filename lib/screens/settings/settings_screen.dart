import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/call_provider.dart';
import '../../providers/sms_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CallProvider, SmsProvider>(
      builder: (context, callProvider, smsProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Call Protection
              _buildSectionTitle(context, 'Call Protection'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.shield_rounded,
                    iconColor: AppTheme.accentGreen,
                    title: 'Call Screening',
                    subtitle: 'Screen incoming calls for spam',
                    trailing: Switch(
                      value: callProvider.callScreeningEnabled,
                      onChanged: callProvider.toggleCallScreening,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.warning_rounded,
                    iconColor: AppTheme.accentRed,
                    title: 'Auto-Block Scams',
                    subtitle: 'Automatically block scam calls',
                    trailing: Switch(
                      value: callProvider.autoBlockScam,
                      onChanged: callProvider.toggleAutoBlockScam,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.campaign_rounded,
                    iconColor: AppTheme.accentOrange,
                    title: 'Auto-Block Telemarketing',
                    subtitle: 'Automatically block telemarketing',
                    trailing: Switch(
                      value: callProvider.autoBlockTelemarketing,
                      onChanged: callProvider.toggleAutoBlockTelemarketing,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // SMS Protection
              _buildSectionTitle(context, 'SMS Protection'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.sms_rounded,
                    iconColor: AppTheme.accentPurple,
                    title: 'SMS Protection',
                    subtitle: 'Scan messages for threats',
                    trailing: Switch(
                      value: smsProvider.smsProtectionEnabled,
                      onChanged: smsProvider.toggleSmsProtection,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.visibility_off_rounded,
                    iconColor: AppTheme.accentOrange,
                    title: 'Safe View',
                    subtitle: 'Disable links in suspicious messages',
                    trailing: Switch(
                      value: smsProvider.safeViewEnabled,
                      onChanged: smsProvider.toggleSafeView,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // Blocked Numbers
              _buildSectionTitle(context, 'Blocked Numbers'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.block_rounded,
                    iconColor: AppTheme.accentRed,
                    title: 'Manage Blocked Numbers',
                    subtitle:
                        '${callProvider.blockedNumbers.length} numbers blocked',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                    onTap: () => _showBlockedNumbers(context, callProvider),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // Privacy
              _buildSectionTitle(context, 'Privacy'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip_rounded,
                    iconColor: AppTheme.primaryBlue,
                    title: 'Privacy Policy',
                    subtitle: 'Your data stays on your device',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.security_rounded,
                    iconColor: AppTheme.accentGreen,
                    title: 'Permissions',
                    subtitle: 'Manage app permissions',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // About
              _buildSectionTitle(context, 'About'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.textSecondary,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.star_outline_rounded,
                    iconColor: AppTheme.accentOrange,
                    title: 'Rate the App',
                    subtitle: 'Help us improve',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppTheme.dividerColor, height: 1, indent: 64);
  }

  void _showBlockedNumbers(BuildContext context, CallProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final numbers = provider.blockedNumbers.toList();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Blocked Numbers',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          '${numbers.length} blocked',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (numbers.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 48, color: AppTheme.accentGreen),
                            const SizedBox(height: 12),
                            Text(
                              'No manually blocked numbers',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.45,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: numbers.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: AppTheme.dividerColor, height: 1),
                          itemBuilder: (context, index) {
                            final number = numbers[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.block_rounded,
                                    color: AppTheme.accentRed, size: 20),
                              ),
                              title: Text(number,
                                  style:
                                      TextStyle(color: AppTheme.textPrimary)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: AppTheme.accentRed),
                                onPressed: () {
                                  provider.unblockNumber(number);
                                  setModalState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
