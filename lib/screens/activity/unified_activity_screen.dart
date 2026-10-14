import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/channel_type.dart';
import '../../models/ai_threat_record.dart';
import '../../providers/fraud_guard_provider.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/ui_kit.dart';

class UnifiedActivityScreen extends StatefulWidget {
  const UnifiedActivityScreen({super.key});

  @override
  State<UnifiedActivityScreen> createState() => _UnifiedActivityScreenState();
}

class _UnifiedActivityScreenState extends State<UnifiedActivityScreen> {
  static const _filters = ['All', 'Blocked', 'Escalated', 'Allowed'];

  ChannelType? _selectedChannel;
  int _filterIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(AiThreatRecord r) {
    final filter = _filters[_filterIndex];
    if (_selectedChannel != null && r.channel != _selectedChannel) return false;
    if (filter == 'Blocked' && !r.decision.isBlocked) return false;
    if (filter == 'Escalated' && r.decision != ThreatDecision.escalatedToUser) {
      return false;
    }
    if (filter == 'Allowed' &&
        (r.decision != ThreatDecision.autoAllowed &&
            r.decision != ThreatDecision.userAllowed)) {
      return false;
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      return r.senderHandle.toLowerCase().contains(query) ||
          r.content.toLowerCase().contains(query) ||
          r.threatCategory.toLowerCase().contains(query);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkBackground,
      child: Consumer<FraudGuardProvider>(
        builder: (context, provider, _) {
          final records = provider.allRecords.where(_matches).toList();
          const pad = AppLayout.pagePadding;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const LargeTitleSliver(title: 'Activity'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(pad, 4, pad, 12),
                  child: _buildSearch(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 38, child: _buildChannelChips()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(pad, 14, pad, 20),
                  child: AppSegmentedControl(
                    segments: [for (final f in _filters) AppSegment(f)],
                    selectedIndex: _filterIndex,
                    onChanged: (i) => setState(() => _filterIndex = i),
                  ),
                ),
              ),
              if (records.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No results',
                    message:
                        'No interactions match your filters. Try a different search or channel.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: pad),
                  sliver: SliverToBoxAdapter(
                    child: GroupedSection(
                      dividerIndent: 70,
                      children: [
                        for (final item in records)
                          ActivityRow(
                            record: item,
                            showDate: true,
                            onTap: () => _showRecordDetail(context, item),
                          ),
                      ],
                    ).appear(),
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

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      textInputAction: TextInputAction.search,
      cursorColor: AppTheme.primaryBlue,
      style: AppFont.sub(
        color: AppTheme.textPrimary,
        fontSize: 16,
        letterSpacing: -0.2,
      ),
      decoration: InputDecoration(
        hintText: 'Search senders, keywords, threats',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        fillColor: AppTheme.isDark
            ? const Color(0xFF162040)
            : const Color(0xFFE6EAF4),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppTheme.textMuted,
          size: 22,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.6),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildChannelChips() {
    final entries = <MapEntry<String, ChannelType?>>[
      const MapEntry('All Channels', null),
      for (final ch in ChannelType.values) MapEntry(ch.displayName, ch),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePadding),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final e = entries[i];
        final selected = _selectedChannel == e.value;
        return PressableScale(
          haptic: true,
          scale: 0.95,
          onTap: () => setState(() => _selectedChannel = e.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppTheme.primaryGradient,
                    )
                  : null,
              color: selected ? null : AppTheme.cardDark,
              border: Border.all(
                color: selected ? Colors.transparent : AppTheme.hairline,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (e.value != null) ...[
                  Icon(
                    e.value!.icon,
                    size: 14,
                    color: selected ? Colors.white : e.value!.color,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  e.key,
                  style: AppFont.main(
                    color: selected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────── Detail sheet ─────────────────────────────

  void _showRecordDetail(BuildContext context, AiThreatRecord item) {
    final color = decisionColor(item.decision);
    final riskColor = item.riskScore >= 70
        ? AppTheme.accentRed
        : item.riskScore >= 40
        ? AppTheme.accentOrange
        : AppTheme.accentGreen;

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
                    icon: item.channel.icon,
                    color: item.channel.color,
                    size: 50,
                  ),
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
                            fontSize: 20,
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
                  RiskGauge(score: item.riskScore, color: riskColor, size: 60),
                ],
              ),
              const SizedBox(height: 20),
              _SheetPanel(
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
              _SheetPanel(
                label: 'AI REASONING & VERDICT',
                icon: Icons.auto_awesome_rounded,
                labelColor: AppTheme.primaryBlue,
                color: AppTheme.primaryBlue.withValues(
                  alpha: AppTheme.isDark ? 0.12 : 0.06,
                ),
                child: Text(
                  item.aiReasoning,
                  style: AppFont.sub(
                    color: AppTheme.textPrimary,
                    fontSize: 14.5,
                    height: 1.45,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GroupedSection(
                children: [
                  AppRow(
                    title: 'Decision',
                    trailing: StatusPill(
                      label: item.decision.label,
                      color: color,
                      icon: decisionIcon(item.decision),
                    ),
                  ),
                  AppRow(
                    title: 'Category',
                    trailing: _Value(item.threatCategory),
                  ),
                  AppRow(
                    title: 'AI confidence',
                    trailing: _Value('${(item.aiConfidence * 100).round()}%'),
                  ),
                  AppRow(
                    title: 'Channel',
                    trailing: _Value(item.channel.displayName),
                  ),
                  AppRow(title: 'Source', trailing: _Value(item.sourceMethod)),
                  AppRow(
                    title: 'Received',
                    trailing: _Value(
                      '${item.formattedDate} · ${item.formattedTime}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Value extends StatelessWidget {
  final String text;
  const _Value(this.text);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Text(
        text,
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppFont.sub(color: AppTheme.textSecondary, fontSize: 15),
      ),
    );
  }
}

class _SheetPanel extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? labelColor;
  final Color color;
  final Widget child;

  const _SheetPanel({
    required this.label,
    this.icon,
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
              if (icon != null) ...[
                Icon(icon, size: 14, color: lc),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppFont.main(
                  color: lc,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
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
