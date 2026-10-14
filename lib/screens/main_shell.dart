import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../core/theme/app_appearance.dart';
import '../core/theme/app_theme.dart';
import '../models/channel_type.dart';
import '../models/ai_threat_record.dart';
import '../providers/call_provider.dart';
import '../providers/sms_provider.dart';
import '../providers/fraud_guard_provider.dart';
import '../widgets/incoming_call_dialog.dart';
import '../widgets/ui_kit.dart';
import 'dashboard/cross_channel_dashboard_screen.dart';
import 'escalations/ai_escalations_screen.dart';
import 'channels/channels_hub_screen.dart';
import 'activity/unified_activity_screen.dart';
import 'settings/ai_settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AppAppearance.instance.addListener(_handleAppearanceChanged);
  }

  @override
  void dispose() {
    AppAppearance.instance.removeListener(_handleAppearanceChanged);
    super.dispose();
  }

  void _handleAppearanceChanged() {
    if (!mounted) return;
    setState(() {});
    AppTheme.applySystemUiStyle();
  }

  void _navigateToTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final fraudProvider = context.watch<FraudGuardProvider>();
    final pendingCount = fraudProvider.pendingEscalationsCount;

    final screens = <Widget>[
      CrossChannelDashboardScreen(onNavigateToTab: _navigateToTab),
      const AiEscalationsScreen(),
      const ChannelsHubScreen(),
      const UnifiedActivityScreen(),
      const AiSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: ShellScope(
        onSimulate: () => _showSimulationModal(context),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.985,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, ?current],
                ),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: screens[_currentIndex],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _FloatingTabBar(
                index: _currentIndex,
                reviewBadge: pendingCount,
                onChanged: _navigateToTab,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── Simulation sheet ─────────────────────────────

  void _showSimulationModal(BuildContext context) {
    showAppSheet<void>(
      context,
      builder: (ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + math.max(MediaQuery.paddingOf(ctx).bottom, 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBadge(
                    icon: Icons.bolt_rounded,
                    color: AppTheme.primaryBlue,
                    size: 44,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulate a Threat',
                          style: AppFont.main(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Watch the AI triage a live event across channels.',
                          style: AppFont.sub(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GroupedSection(
                title: 'Auto-blocked',
                dividerIndent: 62,
                children: [
                  _buildSimRow(
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xFFE1306C),
                    title: 'Instagram crypto airdrop',
                    subtitle: '@elon_airdrop_giveaway_bot · High risk',
                    onTap: () {
                      Navigator.pop(ctx);
                      final record = context
                          .read<FraudGuardProvider>()
                          .processIncomingInteraction(
                            channel: ChannelType.instagram,
                            senderHandle: '@elon_airdrop_giveaway_bot',
                            senderDisplayName: 'Tesla Community Airdrop',
                            content:
                                'You won 2.5 BTC in our private giveaway! Connect wallet: http://claim-tesla-rewards.ru/auth',
                          );
                      _showSimulationResult(context, record);
                    },
                  ),
                  _buildSimRow(
                    icon: Icons.phone_in_talk_rounded,
                    color: AppTheme.accentRedFill,
                    title: 'Voice call · IRS warrant scam',
                    subtitle: '+1 (555) 019-8321 · Blocked by AI',
                    onTap: () {
                      Navigator.pop(ctx);
                      final callRecord = context
                          .read<CallProvider>()
                          .processIncomingCall(
                            phoneNumber: '+1 (555) 019-8321',
                            contactName: 'IRS Impersonator',
                            category: 'Scam',
                            threatLevel: 'High',
                          );
                      context.read<FraudGuardProvider>().processIncomingInteraction(
                        channel: ChannelType.call,
                        senderHandle: '+1 (555) 019-8321',
                        senderDisplayName: 'IRS Impersonator',
                        content:
                            '[Voice Call]: Arrest warrant issued for tax fraud. Press 1 to settle immediately.',
                      );
                      IncomingCallDialog.show(context, callRecord);
                    },
                  ),
                  _buildSimRow(
                    icon: Icons.sms_failed_rounded,
                    color: AppTheme.accentPurple,
                    title: 'SMS bank suspension phishing',
                    subtitle: '+1 (555) 777-9911 · Quarantined',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.read<SmsProvider>().addIncomingSms(
                        sender: '+1 (555) 777-9911',
                        body:
                            'ALERT: Your bank account has been suspended. Restore access: http://secure-bank-login.phish/auth',
                        isThreat: true,
                        threatType: 'Phishing Alert',
                        maliciousLinks: ['http://secure-bank-login.phish/auth'],
                      );
                      final record = context
                          .read<FraudGuardProvider>()
                          .processIncomingInteraction(
                            channel: ChannelType.sms,
                            senderHandle: '+1 (555) 777-9911',
                            content:
                                'ALERT: Your bank account has been suspended. Restore access: http://secure-bank-login.phish/auth',
                          );
                      _showSimulationResult(context, record);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GroupedSection(
                title: 'Needs your review',
                dividerIndent: 62,
                children: [
                  _buildSimRow(
                    icon: Icons.tag_rounded,
                    color: ChannelType.twitter.color,
                    title: 'X ambiguous brand deal',
                    subtitle: '@creator_agency_deal · 65% risk',
                    onTap: () {
                      Navigator.pop(ctx);
                      final record = context
                          .read<FraudGuardProvider>()
                          .processIncomingInteraction(
                            channel: ChannelType.twitter,
                            senderHandle: '@creator_agency_deal',
                            senderDisplayName: 'Creator Collab Media',
                            content:
                                'Hi! We want to sponsor your business with a \$3,000 upfront budget. Please review the campaign brief at: http://creator-brief-deal.xyz/deck',
                          );
                      setState(() => _currentIndex = 1);
                      _showSimulationResult(context, record);
                    },
                  ),
                  _buildSimRow(
                    icon: Icons.alternate_email_rounded,
                    color: AppTheme.accentOrange,
                    title: 'Email wire transfer reroute',
                    subtitle: 'billing@apex-partner.com · 74% risk',
                    onTap: () {
                      Navigator.pop(ctx);
                      final record = context
                          .read<FraudGuardProvider>()
                          .processIncomingInteraction(
                            channel: ChannelType.email,
                            senderHandle: 'billing@apex-partner.com',
                            senderDisplayName: 'Apex Supplier Billing',
                            content:
                                'URGENT: Our bank routing details have changed. Remit outstanding invoice #4920 via wire transfer within 24h to avoid service stoppage.',
                          );
                      setState(() => _currentIndex = 1);
                      _showSimulationResult(context, record);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GroupedSection(
                title: 'Safe',
                dividerIndent: 62,
                children: [
                  _buildSimRow(
                    icon: Icons.chat_rounded,
                    color: AppTheme.accentGreenFill,
                    title: 'WhatsApp verified client',
                    subtitle: '+1 (555) 902-1144 · Auto-allowed',
                    onTap: () {
                      Navigator.pop(ctx);
                      final record = context
                          .read<FraudGuardProvider>()
                          .processIncomingInteraction(
                            channel: ChannelType.whatsapp,
                            senderHandle: '+1 (555) 902-1144',
                            senderDisplayName: 'Client Dr. Emily Stone',
                            content:
                                'Hi! Confirming our strategy session for tomorrow at 2 PM. Looking forward to speaking!',
                          );
                      _showSimulationResult(context, record);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSimulationResult(BuildContext context, AiThreatRecord record) {
    final isBlocked = record.decision == ThreatDecision.autoBlocked;
    final isEscalated = record.decision == ThreatDecision.escalatedToUser;

    showAppSnack(
      context,
      icon: isBlocked
          ? Icons.block_rounded
          : isEscalated
          ? Icons.psychology_alt_rounded
          : Icons.check_circle_rounded,
      color: isBlocked
          ? AppTheme.accentRed
          : isEscalated
          ? AppTheme.accentOrange
          : AppTheme.accentGreen,
      message:
          'AI triage: ${record.decision.label} · ${record.riskScore}% risk',
      actionLabel: isEscalated ? 'View' : null,
      onAction: () => setState(() => _currentIndex = 1),
    );
  }

  Widget _buildSimRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppRow(
      leading: AppIconBadge(icon: icon, color: color, size: 34),
      title: title,
      subtitle: subtitle,
      showChevron: true,
      onTap: () {
        AppHaptics.medium();
        onTap();
      },
    );
  }
}

// ───────────────────────────── Floating tab bar ─────────────────────────────

class _TabSpec {
  final IconData icon;
  final String label;
  const _TabSpec(this.icon, this.label);
}

class _FloatingTabBar extends StatelessWidget {
  final int index;
  final int reviewBadge;
  final ValueChanged<int> onChanged;

  const _FloatingTabBar({
    required this.index,
    required this.reviewBadge,
    required this.onChanged,
  });

  static const _tabs = [
    _TabSpec(Icons.shield_rounded, 'Shield'),
    _TabSpec(Icons.psychology_alt_rounded, 'Review'),
    _TabSpec(Icons.hub_rounded, 'Channels'),
    _TabSpec(Icons.history_rounded, 'Activity'),
    _TabSpec(Icons.tune_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(MediaQuery.paddingOf(context).bottom, 12.0);
    const radius = 32.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppTheme.isDark ? 0.5 : 0.1,
              ),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 68,
              decoration: ShapeDecoration(
                color: AppTheme.glass,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: BorderSide(
                    color: AppTheme.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.9),
                    width: 0.8,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cell = constraints.maxWidth / _tabs.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutBack,
                        left: cell * index,
                        top: 0,
                        bottom: 0,
                        width: cell,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: AppTheme.primaryBlue.withValues(
                              alpha: AppTheme.isDark ? 0.18 : 0.09,
                            ),
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < _tabs.length; i++)
                            Expanded(
                              child: _TabItem(
                                spec: _tabs[i],
                                selected: i == index,
                                badge: i == 1 ? reviewBadge : 0,
                                onTap: () {
                                  if (i != index) AppHaptics.selection();
                                  onChanged(i);
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final _TabSpec spec;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _TabItem({
    required this.spec,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryBlue : AppTheme.textMuted;
    Widget icon = AnimatedScale(
      scale: selected ? 1.08 : 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      child: Icon(spec.icon, size: 23, color: color),
    );
    if (badge > 0) {
      icon = Badge(
        label: Text('$badge'),
        backgroundColor: AppTheme.accentOrange,
        textColor: AppTheme.onAccentOrange,
        child: icon,
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: spec.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppFont.main(
                color: color,
                fontSize: 10.5,
                letterSpacing: -0.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(spec.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
