import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../models/blocking_stats.dart';
import '../../providers/call_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/ui_kit.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const _periods = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = provider.stats;
        final selected = _periods.indexOf(provider.selectedPeriod);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.pagePadding,
            8,
            AppLayout.pagePadding,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSegmentedControl(
                segments: [for (final p in _periods) AppSegment(p)],
                selectedIndex: selected < 0 ? 0 : selected,
                onChanged: (i) => provider.setSelectedPeriod(_periods[i]),
              ).appear(),

              const SizedBox(height: 20),

              _TotalCard(
                total: stats.totalBlocked,
                period: provider.selectedPeriod,
              ).appear(index: 1),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.warning_rounded,
                      label: 'Scam',
                      value: '${stats.scamBlocked}',
                      color: AppTheme.accentRedFill,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.campaign_rounded,
                      label: 'Telemarketing',
                      value: '${stats.telemarketingBlocked}',
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ],
              ).appear(index: 2),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.more_horiz_rounded,
                      label: 'Other',
                      value: '${stats.otherBlocked}',
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.sms_rounded,
                      label: 'SMS Blocked',
                      value: '${stats.smsBlocked}',
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ],
              ).appear(index: 3),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Expanded(
                    child: SectionHeader(title: 'Blocking Activity'),
                  ),
                  _LegendDot(color: AppTheme.accentRed, label: 'Blocked'),
                  const SizedBox(width: 14),
                  _LegendDot(color: AppTheme.primaryBlue, label: 'Identified'),
                ],
              ),
              const SizedBox(height: 14),
              AppSurface(
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 12),
                child: SizedBox(
                  height: 210,
                  child: _buildBarChart(stats, provider.selectedPeriod),
                ),
              ).appear(index: 4),

              const SizedBox(height: 32),

              const SectionHeader(title: 'Category Distribution'),
              const SizedBox(height: 14),
              AppSurface(
                padding: const EdgeInsets.all(18),
                child: SizedBox(height: 180, child: _buildPieChart(stats)),
              ).appear(index: 5),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart(BlockingStats stats, String selectedPeriod) {
    if (stats.dailyStats.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: AppFont.sub(color: AppTheme.textMuted),
        ),
      );
    }

    final calculatedMax = stats.dailyStats.fold<double>(0.0, (maxVal, s) {
      final val = (s.blocked + s.identified).toDouble();
      return val > maxVal ? val : maxVal;
    });
    final effectiveMaxY = (calculatedMax > 0 ? calculatedMax * 1.25 : 20.0)
        .ceilToDouble();
    final rodWidth = selectedPeriod == 'Year' ? 6.0 : 8.0;
    final blockedColor = AppTheme.accentRed;
    final identifiedColor = AppTheme.primaryBlue;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: effectiveMaxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.snackBarBackground,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isBlocked = rodIndex == 0;
              return BarTooltipItem(
                '${isBlocked ? "Blocked" : "Screened"}: ${rod.toY.toInt()}',
                AppFont.main(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.dailyStats.length) {
                  return const SizedBox();
                }
                if (value != index.toDouble()) return const SizedBox();
                final date = stats.dailyStats[index].date;
                String label;
                if (selectedPeriod == 'Week') {
                  const weekdays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  label = weekdays[(date.weekday - 1) % 7];
                } else if (selectedPeriod == 'Year') {
                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  label = months[(date.month - 1) % 12];
                } else {
                  label = '${date.day}';
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: AppFont.sub(
                      color: AppTheme.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: effectiveMaxY / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.hairline, strokeWidth: 0.8),
        ),
        barGroups: stats.dailyStats.asMap().entries.map<BarChartGroupData>((
          entry,
        ) {
          return BarChartGroupData(
            x: entry.key,
            barsSpace: 3,
            barRods: [
              BarChartRodData(
                toY: entry.value.blocked.toDouble(),
                color: blockedColor,
                width: rodWidth,
                borderRadius: BorderRadius.circular(rodWidth / 2),
              ),
              BarChartRodData(
                toY: entry.value.identified.toDouble(),
                color: identifiedColor.withValues(alpha: 0.55),
                width: rodWidth,
                borderRadius: BorderRadius.circular(rodWidth / 2),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(BlockingStats stats) {
    if (stats.totalBlocked <= 0) {
      return Center(
        child: Text(
          'No data available',
          style: AppFont.sub(color: AppTheme.textMuted),
        ),
      );
    }

    final slices = <_Slice>[
      _Slice('Scam', stats.scamBlocked, AppTheme.accentRedFill),
      _Slice(
        'Telemarketing',
        stats.telemarketingBlocked,
        AppTheme.accentOrange,
      ),
      _Slice('Other', stats.otherBlocked, AppTheme.primaryBlue),
    ].where((s) => s.value > 0).toList();

    if (slices.isEmpty) {
      return Center(
        child: Text(
          'No category distribution available',
          style: AppFont.sub(color: AppTheme.textMuted),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 52,
                  sections: [
                    for (final s in slices)
                      PieChartSectionData(
                        value: s.value.toDouble(),
                        color: s.color,
                        showTitle: false,
                        radius: 20,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stats.totalBlocked}',
                    style: AppFont.main(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'blocked',
                    style: AppFont.sub(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in slices) ...[
              _SliceLegend(slice: s, total: stats.totalBlocked),
              if (s != slices.last) const SizedBox(height: 14),
            ],
          ],
        ),
      ],
    );
  }
}

class _Slice {
  final String label;
  final int value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class _SliceLegend extends StatelessWidget {
  final _Slice slice;
  final int total;
  const _SliceLegend({required this.slice, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = ((slice.value / total) * 100).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slice.label,
              style: AppFont.main(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${slice.value} · $pct%',
              style: AppFont.sub(color: AppTheme.textMuted, fontSize: 12.5),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFont.sub(color: AppTheme.textMuted, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int total;
  final String period;
  const _TotalCard({required this.total, required this.period});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: 28,
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppTheme.heroGradient,
      ),
      borderColor: Colors.white.withValues(alpha: 0.12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL BLOCKED',
                  style: AppFont.main(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: total.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    '${v.round()}',
                    style: AppFont.main(
                      color: Colors.white,
                      fontSize: 58,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      height: 1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calls blocked · $period',
                  style: AppFont.main(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.shield_rounded,
            size: 72,
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ],
      ),
    );
  }
}
