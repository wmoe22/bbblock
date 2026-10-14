import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/channel_type.dart';
import '../../providers/fraud_guard_provider.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/ui_kit.dart';

class CrossChannelDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const CrossChannelDashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkBackground,
      child: Consumer<FraudGuardProvider>(
        builder: (context, provider, _) {
          final pendingCount = provider.pendingEscalationsCount;
          final blockedCount = provider.blockedRecords.length;
          final totalScanned = provider.allRecords.length;
          // The three most important items: pending reviews first, then the
          // highest-risk interactions, newest first as the tiebreaker.
          final recentRecords =
              ([...provider.allRecords]..sort((a, b) {
                    final aReview = a.decision.isPendingEscalation ? 0 : 1;
                    final bReview = b.decision.isPendingEscalation ? 0 : 1;
                    if (aReview != bReview) return aReview.compareTo(bReview);
                    if (a.riskScore != b.riskScore) {
                      return b.riskScore.compareTo(a.riskScore);
                    }
                    return b.timestamp.compareTo(a.timestamp);
                  }))
                  .take(3)
                  .toList();

          const pad = EdgeInsets.symmetric(horizontal: AppLayout.pagePadding);

          return CustomScrollView(
            slivers: [
              const LargeTitleSliver(title: 'Shield'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: 8),
                  child: _HeroCard(
                    blocked: blockedCount,
                    review: pendingCount,
                    scanned: totalScanned,
                  ).appear(),
                ),
              ),
              if (pendingCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pad.copyWith(top: 14),
                    child: _ReviewBanner(
                      count: pendingCount,
                      onTap: () => onNavigateToTab?.call(1),
                    ).appear(index: 1),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: 32, bottom: 12),
                  child: SectionHeader(
                    title: 'Channels',
                    actionLabel: 'Manage',
                    onAction: () => onNavigateToTab?.call(2),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 84,
                  child: _ChannelStrip(provider: provider),
                ).appear(index: 2),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: 32, bottom: 12),
                  child: const SectionHeader(title: 'Threats by Channel'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad,
                  child: _ThreatBreakdown(
                    counts: provider.channelThreatCounts,
                  ).appear(index: 3),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: 32, bottom: 12),
                  child: SectionHeader(
                    title: 'Live Activity',
                    actionLabel: 'See All',
                    onAction: () => onNavigateToTab?.call(3),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad,
                  child: recentRecords.isEmpty
                      ? const SizedBox.shrink()
                      : GroupedSection(
                          dividerIndent: 70,
                          children: [
                            for (final r in recentRecords)
                              ActivityRow(record: r),
                          ],
                        ).appear(index: 4),
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
}

// ─────────────────────────────── Hero ───────────────────────────────

class _HeroCard extends StatelessWidget {
  final int blocked;
  final int review;
  final int scanned;

  const _HeroCard({
    required this.blocked,
    required this.review,
    required this.scanned,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.heroGradient;
    return AppSurface(
      radius: 30,
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderColor: Colors.white.withValues(alpha: 0.12),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -34,
            child: Icon(
              Icons.shield_rounded,
              size: 190,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _ShieldOrb(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AppTheme.isDark
                                      ? const Color(0xFF34D17F)
                                      : const Color(0xFF5BE49B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'AI SHIELD ACTIVE',
                                style: AppFont.main(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "You're protected",
                            style: AppFont.main(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Calls, texts, DMs and email are triaged by AI in real time, and anything unclear comes to you.',
                  style: AppFont.sub(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _HeroStat(value: blocked, label: 'Blocked'),
                      const _HeroDivider(),
                      _HeroStat(value: review, label: 'To review'),
                      const _HeroDivider(),
                      _HeroStat(value: scanned, label: 'Scanned'),
                    ],
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

class _ShieldOrb extends StatelessWidget {
  const _ShieldOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                begin: 0.8,
                end: 1.25,
                duration: 2400.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 2400.ms, curve: Curves.easeOut),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final int value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '${v.round()}',
              style: AppFont.main(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                height: 1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppFont.main(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 0.8,
    height: 30,
    color: Colors.white.withValues(alpha: 0.14),
  );
}

// ─────────────────────────────── Review banner ───────────────────────────────

class _ReviewBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ReviewBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.accentOrange;
    return AppSurface(
      radius: 22,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderColor: color.withValues(alpha: 0.35),
      child: Row(
        children: [
          AppIconBadge(
            icon: Icons.psychology_alt_rounded,
            color: color,
            size: 42,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              count == 1
                  ? '1 interaction needs your review'
                  : '$count interactions need your review',
              style: AppFont.main(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Channels ───────────────────────────────

class _ChannelStrip extends StatelessWidget {
  final FraudGuardProvider provider;
  const _ChannelStrip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final channels = provider.channelConfigs;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.pagePadding,
        vertical: 4,
      ),
      itemCount: channels.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final c = channels[index];
        final type = c.channel;
        return SizedBox(
          width: 160,
          child: AppSurface(
            radius: 20,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AppIconBadge(
                  icon: type.icon,
                  color: type.color,
                  size: 38,
                  soft: !c.isEnabled,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.main(
                          color: AppTheme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.isEnabled
                                  ? AppTheme.accentGreen
                                  : AppTheme.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              c.isEnabled
                                  ? '${c.totalScanned} scanned'
                                  : 'Paused',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFont.sub(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────── Threat breakdown ───────────────────────────────

class _ThreatBreakdown extends StatelessWidget {
  final Map<ChannelType, int> counts;
  const _ThreatBreakdown({required this.counts});

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) {
      return AppSurface(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No threats recorded today',
              style: AppFont.sub(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ),
        ),
      );
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = entries.first.value;

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  AppIconBadge(
                    icon: e.key.icon,
                    color: e.key.color,
                    size: 30,
                    soft: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.key.displayName,
                          style: AppFont.main(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 7),
                        _Bar(fraction: e.value / maxValue),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${e.value}',
                    style: AppFont.main(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

class _Bar extends StatelessWidget {
  final double fraction;
  const _Bar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction.clamp(0.04, 1.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 6,
          color: AppTheme.primaryBlue.withValues(alpha: 0.12),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppTheme.primaryGradient),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
