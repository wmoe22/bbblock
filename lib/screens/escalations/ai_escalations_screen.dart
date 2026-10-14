import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_threat_record.dart';
import '../../models/channel_type.dart';
import '../../providers/fraud_guard_provider.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/ui_kit.dart';

class AiEscalationsScreen extends StatefulWidget {
  const AiEscalationsScreen({super.key});

  @override
  State<AiEscalationsScreen> createState() => _AiEscalationsScreenState();
}

class _AiEscalationsScreenState extends State<AiEscalationsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkBackground,
      child: Consumer<FraudGuardProvider>(
        builder: (context, provider, _) {
          final pending = provider.pendingEscalations;
          final resolved = provider.allRecords
              .where(
                (r) =>
                    r.decision == ThreatDecision.userBlocked ||
                    r.decision == ThreatDecision.userAllowed,
              )
              .toList();

          const pad = AppLayout.pagePadding;

          return CustomScrollView(
            slivers: [
              const LargeTitleSliver(title: 'Review'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(pad, 0, pad, 16),
                  child: Text(
                    "When the AI can't tell, it asks you. Decide once and every channel stays in sync.",
                    style: AppFont.sub(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.4,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(pad, 0, pad, 20),
                  child: AppSegmentedControl(
                    selectedIndex: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                    segments: [
                      AppSegment('Pending Decision', badge: pending.length),
                      AppSegment('Resolved (${resolved.length})'),
                    ],
                  ),
                ),
              ),
              if (_tab == 0) ..._pendingSlivers(pending, provider),
              if (_tab == 1) ..._resolvedSlivers(resolved),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppLayout.bottomInset),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _pendingSlivers(
    List<AiThreatRecord> items,
    FraudGuardProvider provider,
  ) {
    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.check_circle_rounded,
            color: AppTheme.accentGreenFill,
            title: 'All clear',
            message:
                'The AI has triaged everything across your channels. Nothing needs your attention.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePadding),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 18),
          itemBuilder: (context, index) => _EscalationCard(
            item: items[index],
            provider: provider,
          ).appear(index: index),
        ),
      ),
    ];
  }

  List<Widget> _resolvedSlivers(List<AiThreatRecord> items) {
    if (items.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.inbox_rounded,
            title: 'No decisions yet',
            message: 'Interactions you block or allow will be listed here.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePadding),
        sliver: SliverToBoxAdapter(
          child: GroupedSection(
            dividerIndent: 70,
            children: [for (final item in items) _ResolvedRow(item: item)],
          ).appear(),
        ),
      ),
    ];
  }
}

// ─────────────────────────────── Pending card ───────────────────────────────

class _EscalationCard extends StatelessWidget {
  final AiThreatRecord item;
  final FraudGuardProvider provider;

  const _EscalationCard({required this.item, required this.provider});

  Color get _riskColor => item.riskScore >= 70
      ? AppTheme.accentRed
      : item.riskScore >= 40
      ? AppTheme.accentOrange
      : AppTheme.accentGreen;

  @override
  Widget build(BuildContext context) {
    final channel = item.channel;

    return AppSurface(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel · source · time
          Row(
            children: [
              StatusPill(
                label: channel.displayName,
                color: channel.color,
                icon: channel.icon,
              ),
              const Spacer(),
              Text(
                item.formattedTime,
                style: AppFont.sub(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sender + risk gauge
          Row(
            children: [
              _Avatar(letter: item.senderHandle, color: channel.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderTitle(item),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.main(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.senderHandle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.sub(
                        color: AppTheme.textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              RiskGauge(score: item.riskScore, color: _riskColor, size: 60),
            ],
          ),
          const SizedBox(height: 18),

          // Message
          _Panel(
            label: 'MESSAGE',
            color: AppTheme.surfaceDark,
            child: Text(
              item.content,
              style: AppFont.sub(
                color: AppTheme.textPrimary,
                fontSize: 15,
                height: 1.45,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // AI analysis
          _Panel(
            label: item.threatCategory.toUpperCase(),
            labelIcon: Icons.auto_awesome_rounded,
            labelColor: AppTheme.primaryBlue,
            color: AppTheme.primaryBlue.withValues(
              alpha: AppTheme.isDark ? 0.12 : 0.06,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.aiReasoning,
                  style: AppFont.sub(
                    color: AppTheme.textPrimary,
                    fontSize: 14.5,
                    height: 1.45,
                    letterSpacing: -0.2,
                  ),
                ),
                if (item.riskIndicators.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final factor in item.riskIndicators)
                        StatusPill(
                          label: factor,
                          color: AppTheme.accentOrange,
                          icon: Icons.warning_amber_rounded,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Block & Sync',
                  icon: Icons.block_rounded,
                  kind: AppButtonKind.destructive,
                  fontSize: 15,
                  onPressed: () {
                    provider.resolveEscalation(item.id, true);
                    showAppSnack(
                      context,
                      icon: Icons.shield_rounded,
                      color: AppTheme.accentRed,
                      message:
                          'Blocked ${item.senderHandle} and synced the blocklist to Pipedream.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Allow & Whitelist',
                  icon: Icons.check_circle_rounded,
                  kind: AppButtonKind.tinted,
                  color: AppTheme.accentGreen,
                  fontSize: 15,
                  onPressed: () {
                    provider.resolveEscalation(item.id, false);
                    showAppSnack(
                      context,
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.accentGreen,
                      message:
                          'Allowed ${item.senderHandle}. Whitelisted across all channels.',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;
  final Color color;
  const _Avatar({required this.letter, required this.color});

  @override
  Widget build(BuildContext context) {
    final clean = letter.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final text = clean.isNotEmpty ? clean[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.9),
            Color.lerp(color, Colors.black, 0.35)!,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppFont.main(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String label;
  final IconData? labelIcon;
  final Color? labelColor;
  final Color color;
  final Widget child;

  const _Panel({
    required this.label,
    this.labelIcon,
    this.labelColor,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final lc = labelColor ?? AppTheme.textMuted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (labelIcon != null) ...[
                Icon(labelIcon, size: 14, color: lc),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.main(
                    color: lc,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────── Resolved row ───────────────────────────────

class _ResolvedRow extends StatelessWidget {
  final AiThreatRecord item;
  const _ResolvedRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isBlocked = item.decision == ThreatDecision.userBlocked;
    final color = isBlocked ? AppTheme.accentRed : AppTheme.accentGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          AppIconBadge(
            icon: isBlocked ? Icons.block_rounded : Icons.check_circle_rounded,
            color: isBlocked
                ? AppTheme.accentRedFill
                : AppTheme.accentGreenFill,
            size: 40,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        senderTitle(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.main(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.5,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      label: item.channel.displayName,
                      color: item.channel.color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.resolutionNote ??
                      (isBlocked ? 'Blocked by owner' : 'Allowed by owner'),
                  style: AppFont.sub(color: color, fontSize: 13.5, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.formattedTime,
            style: AppFont.sub(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
