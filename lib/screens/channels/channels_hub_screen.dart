import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/channel_type.dart';
import '../../models/pipedream_channel_config.dart';
import '../../models/ai_threat_record.dart';
import '../../providers/fraud_guard_provider.dart';

import '../../widgets/ui_kit.dart';

class ChannelsHubScreen extends StatelessWidget {
  const ChannelsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkBackground,
      child: Consumer<FraudGuardProvider>(
        builder: (context, provider, _) {
          final configs = provider.channelConfigs;
          final active = configs.where((c) => c.isEnabled).length;
          const pad = EdgeInsets.symmetric(horizontal: AppLayout.pagePadding);

          return CustomScrollView(
            slivers: [
              const LargeTitleSliver(title: 'Channels'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: 4),
                  child: _buildHowItWorks().appear(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: 32, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Connected · $active of ${configs.length}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.main(
                            color: AppTheme.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SimulateButton(
                        onTap: () {
                          final shell = ShellScope.maybeOf(context);
                          if (shell != null) {
                            shell.onSimulate();
                          } else {
                            _showQuickSimulateSheet(context, provider);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: pad,
                sliver: SliverList.separated(
                  itemCount: configs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ChannelCard(
                    config: configs[index],
                    provider: provider,

                    onSimulate: () => _simulateEventForChannel(
                      context,
                      provider,
                      configs[index].channel,
                    ),
                  ).appear(index: index),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppLayout.bottomInset),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHowItWorks() {
    return GroupedSection(
      title: 'How ingestion works',
      dividerIndent: 62,
      footer:
          'Every route feeds the same AI triage pipeline, so a decision made on one channel protects all of them.',
      children: [
        AppRow(
          leading: AppIconBadge(
            icon: Icons.notifications_active_rounded,
            color: AppTheme.accentGreenFill,
            size: 34,
          ),
          title: 'Notification interceptor',
          subtitle:
              'On-device capture of Instagram, X and Messenger DMs for personal accounts. No platform API keys required.',
        ),
        AppRow(
          leading: AppIconBadge(
            icon: Icons.webhook_rounded,
            color: AppTheme.primaryBlue,
            size: 34,
          ),
          title: 'Pipedream webhooks',
          subtitle:
              'Meta Business Pages, Twilio Voice/SMS and X webhooks relayed to the AI pipeline in real time.',
        ),
        AppRow(
          leading: AppIconBadge(
            icon: Icons.mark_email_read_rounded,
            color: AppTheme.accentOrange,
            size: 34,
          ),
          title: 'Email forwarding relay',
          subtitle:
              'Universal fallback. DM alert emails are forwarded to a Pipedream inbox for parsing.',
        ),
      ],
    );
  }

  // ───────────────────────────── Sheets ─────────────────────────────

  void _showQuickSimulateSheet(
    BuildContext context,
    FraudGuardProvider provider,
  ) {
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
              Text(
                'Simulate Inbound Event',
                style: AppFont.main(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a channel to test real-time triage and owner escalation.',
                style: AppFont.sub(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 20),
              GroupedSection(
                dividerIndent: 62,
                children: [
                  for (final ch in ChannelType.values.take(5))
                    AppRow(
                      leading: AppIconBadge(
                        icon: ch.icon,
                        color: ch.color,
                        size: 34,
                      ),
                      title: ch.displayName,
                      subtitle: 'Incoming message from ${ch.displayName}',
                      showChevron: true,
                      onTap: () {
                        Navigator.pop(ctx);
                        _simulateEventForChannel(context, provider, ch);
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

  void _simulateEventForChannel(
    BuildContext context,
    FraudGuardProvider provider,
    ChannelType channel,
  ) {
    String sender;
    String content;

    switch (channel) {
      case ChannelType.instagram:
        sender = '@influencer_agency_collab_99';
        content =
            'Hey! We want to buy 100 units of your products right now. Click our order procurement portal: http://procure-agency.xyz/rfp';
        break;
      case ChannelType.twitter:
        sender = '@crypto_insider_whale';
        content =
            'URGENT: Exclusive private seed allocation for verified business accounts. Connect wallet: http://binance-airdrop-priv.top';
        break;
      case ChannelType.facebook:
        sender = 'Marketplace Buyer (Mark)';
        content =
            'Is this still available? I will send an extra \$50 for shipping if you accept Zelle right now.';
        break;
      case ChannelType.call:
        sender = '+1 (555) 492-0012';
        content =
            '[Voice Transcript]: Legal summons notification regarding federal tax audit. Press 1 to speak with an investigator.';
        break;
      case ChannelType.sms:
        sender = '+1 (555) 881-2244';
        content =
            'USPS ALERT: Package delivery suspended due to invalid postal address. Update details: http://usps-re-delivery.top/auth';
        break;
      case ChannelType.whatsapp:
        sender = '+1 (555) 762-1199';
        content =
            'Hello! Can we get a quotation for 10 seats of your enterprise consulting program?';
        break;
      case ChannelType.email:
        sender = 'billing-update@global-cloud-vendor.com';
        content =
            'IMPORTANT: Your cloud servers will be terminated within 24 hours due to failed billing. Update payment card now.';
        break;
      case ChannelType.webhook:
        sender = 'Webhook Event (Stripe/CRM)';
        content =
            'New customer inquiry submitted via contact form with suspicious spoofed IP origin.';
        break;
    }

    final record = provider.processIncomingInteraction(
      channel: channel,
      senderHandle: sender,
      content: content,
    );

    final blocked = record.decision == ThreatDecision.autoBlocked;
    final escalated = record.decision == ThreatDecision.escalatedToUser;

    showAppSnack(
      context,
      icon: blocked
          ? Icons.block_rounded
          : escalated
          ? Icons.psychology_alt_rounded
          : Icons.check_circle_rounded,
      color: blocked
          ? AppTheme.accentRed
          : escalated
          ? AppTheme.accentOrange
          : AppTheme.accentGreen,
      message:
          '${channel.displayName}: ${record.decision.label} · ${record.riskScore}% risk',
    );
  }
}

// ─────────────────────────────── Channel card ───────────────────────────────

class _ChannelCard extends StatelessWidget {
  final PipedreamChannelConfig config;
  final FraudGuardProvider provider;
  final VoidCallback onCode;
  final VoidCallback onSimulate;

  const _ChannelCard({
    required this.config,
    required this.provider,
    required this.onCode,
    required this.onSimulate,
  });

  @override
  Widget build(BuildContext context) {
    final channel = config.channel;

    return AppSurface(
      radius: 26,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                AppIconBadge(
                  icon: channel.icon,
                  color: channel.color,
                  size: 46,
                  soft: !config.isEnabled,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.main(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          StatusPill(
                            label: config.isEnabled ? 'Active' : 'Paused',
                            color: config.isEnabled
                                ? AppTheme.accentGreen
                                : AppTheme.textMuted,
                            dot: true,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              config.mode.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFont.sub(
                                color: AppTheme.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppSwitch(
                  value: config.isEnabled,
                  onChanged: (val) => provider.toggleChannel(channel, val),
                ),
              ],
            ),
          ),
          const AppHairline(),
          IntrinsicHeight(
            child: Row(
              children: [
                _Metric(
                  label: 'Scanned',
                  value: config.totalScanned,
                  color: AppTheme.textPrimary,
                ),
                Container(width: 0.6, color: AppTheme.hairline),
                _Metric(
                  label: 'Blocked',
                  value: config.totalBlocked,
                  color: AppTheme.accentRed,
                ),
                Container(width: 0.6, color: AppTheme.hairline),
                _Metric(
                  label: 'Escalated',
                  value: config.totalEscalated,
                  color: AppTheme.accentOrange,
                ),
              ],
            ),
          ),
          const AppHairline(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Workflow Code',
                    icon: Icons.code_rounded,
                    kind: AppButtonKind.tinted,
                    height: 42,
                    fontSize: 14,
                    onPressed: onCode,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Test Event',
                    icon: Icons.play_arrow_rounded,
                    kind: AppButtonKind.tinted,
                    color: AppTheme.accentGreen,
                    height: 42,
                    fontSize: 14,
                    onPressed: onSimulate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppFont.main(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppFont.sub(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
