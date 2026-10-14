import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_appearance.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/fraud_guard_provider.dart';
import '../../widgets/ui_kit.dart';
import '../stats/stats_screen.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  late TextEditingController _webhookUrlController;
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FraudGuardProvider>();
    _webhookUrlController = TextEditingController(
      text: provider.pipedreamWebhookUrl,
    );
    _apiKeyController = TextEditingController(text: provider.pipedreamApiKey);
  }

  @override
  void dispose() {
    _webhookUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkBackground,
      child: Consumer<FraudGuardProvider>(
        builder: (context, provider, _) {
          const pad = EdgeInsets.symmetric(horizontal: AppLayout.pagePadding);

          Widget section(Widget child, int index, {double top = 28}) =>
              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.copyWith(top: top),
                  child: child.appear(index: index),
                ),
              );

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const LargeTitleSliver(title: 'Settings'),
              section(_buildAppearance(), 0, top: 4),
              section(_buildTriage(provider), 1),
              section(_buildPipedream(context, provider), 2),
              section(_buildAnalytics(context), 3),
              section(_buildPrivacy(), 4),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Center(
                    child: Text(
                      'BBBlock · Version ${AppConstants.appVersion}',
                      style: AppFont.sub(
                        color: AppTheme.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
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

  // ───────────────────────────── Appearance ─────────────────────────────

  Widget _buildAppearance() {
    final isDark = AppAppearance.instance.isDark;
    return GroupedSection(
      title: 'Appearance',
      footer: 'Navy and white by day, midnight and black by night.',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _ThemeTile(
                  label: 'Light',
                  selected: !isDark,
                  dark: false,
                  onTap: () =>
                      AppAppearance.instance.setMode(AppAppearanceMode.light),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ThemeTile(
                  label: 'Dark',
                  selected: isDark,
                  dark: true,
                  onTap: () =>
                      AppAppearance.instance.setMode(AppAppearanceMode.dark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────── Triage ─────────────────────────────

  Widget _buildTriage(FraudGuardProvider provider) {
    final allow = provider.autoAllowThreshold;
    final block = provider.autoBlockThreshold;

    return GroupedSection(
      title: 'AI Screening Engine',
      footer:
          'Interactions scoring between the two thresholds are escalated to you for a final decision.',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBadge(
                    icon: Icons.psychology_rounded,
                    color: AppTheme.primaryBlue,
                    size: 34,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Three-tier triage',
                          style: AppFont.main(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'When the AI blocks, asks you, or allows',
                          style: AppFont.sub(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _TriageBar(allow: allow, block: block),
              const SizedBox(height: 22),
              _ThresholdHeader(
                title: 'Auto-block',
                value: '≥ $block%',
                color: AppTheme.accentRed,
              ),
              Slider(
                value: block.toDouble(),
                min: 50,
                max: 95,
                divisions: 9,
                onChanged: (val) {
                  if (val > allow) {
                    provider.updateThresholds(autoBlock: val.toInt());
                  }
                },
              ),
              Text(
                'Fraud scoring at or above this is blocked automatically.',
                style: AppFont.sub(color: AppTheme.textMuted, fontSize: 12.5),
              ),
              const SizedBox(height: 18),
              const AppHairline(),
              const SizedBox(height: 18),
              _ThresholdHeader(
                title: 'Auto-allow',
                value: '< $allow%',
                color: AppTheme.accentGreen,
              ),
              Slider(
                value: allow.toDouble(),
                min: 10,
                max: 50,
                divisions: 8,
                onChanged: (val) {
                  if (val < block) {
                    provider.updateThresholds(autoAllow: val.toInt());
                  }
                },
              ),
              Text(
                'Clean interactions below this are allowed automatically.',
                style: AppFont.sub(color: AppTheme.textMuted, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────── Pipedream ─────────────────────────────

  Widget _buildPipedream(BuildContext context, FraudGuardProvider provider) {
    return GroupedSection(
      title: 'Pipedream Cloud',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBadge(
                    icon: Icons.webhook_rounded,
                    color: AppTheme.accentPurple,
                    size: 34,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Webhook connection',
                    style: AppFont.main(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _FieldLabel('Inbound endpoint URL'),
              const SizedBox(height: 8),
              TextField(
                controller: _webhookUrlController,
                keyboardType: TextInputType.url,
                cursorColor: AppTheme.primaryBlue,
                style: AppFont.sub(
                  color: AppTheme.textPrimary,
                  fontSize: 14.5,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel('API key (optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                cursorColor: AppTheme.primaryBlue,
                style: AppFont.sub(
                  color: AppTheme.textPrimary,
                  fontSize: 14.5,
                  letterSpacing: -0.2,
                ),
                decoration: const InputDecoration(hintText: 'pd_live_…'),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Save Configuration',
                icon: Icons.check_rounded,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  provider.updatePipedreamSettings(
                    webhookUrl: _webhookUrlController.text.trim(),
                    apiKey: _apiKeyController.text.trim(),
                  );
                  showAppSnack(
                    context,
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.accentGreen,
                    message: 'Pipedream configuration updated.',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────── Analytics ─────────────────────────────

  Widget _buildAnalytics(BuildContext context) {
    return GroupedSection(
      title: 'Reports',
      children: [
        AppRow(
          leading: AppIconBadge(
            icon: Icons.bar_chart_rounded,
            color: AppTheme.primaryBlue,
            size: 34,
          ),
          title: 'Threat & Call Analytics',
          subtitle: 'Historical charts, block rates and categories',
          showChevron: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (ctx) => Scaffold(
                  backgroundColor: AppTheme.darkBackground,
                  appBar: AppBar(
                    title: const Text('Analytics'),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: () => Navigator.maybePop(ctx),
                    ),
                  ),
                  body: const StatsScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ───────────────────────────── Privacy ─────────────────────────────

  Widget _buildPrivacy() {
    return GroupedSection(
      title: 'Privacy',
      children: [
        AppRow(
          leading: AppIconBadge(
            icon: Icons.lock_rounded,
            color: AppTheme.accentGreenFill,
            size: 34,
          ),
          title: 'Zero-log data privacy',
          subtitle:
              'Interactions screened on-device via the notification listener stay private. Webhook payloads pass only through your own Pipedream account, end-to-end encrypted.',
        ),
      ],
    );
  }
}

// ─────────────────────────────── Parts ───────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppFont.sub(
      color: AppTheme.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _ThresholdHeader extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ThresholdHeader({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppFont.main(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        StatusPill(label: value, color: color),
      ],
    );
  }
}

class _TriageBar extends StatelessWidget {
  final int allow;
  final int block;
  const _TriageBar({required this.allow, required this.block});

  @override
  Widget build(BuildContext context) {
    Widget seg(int flex, Color color) => Expanded(
      flex: flex.clamp(1, 100),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );

    Widget label(String text, Color color) => Text(
      text,
      style: AppFont.main(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            label('Safe', AppTheme.accentGreen),
            label('Review · $allow–$block%', AppTheme.accentOrange),
            label('Block', AppTheme.accentRed),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Row(
            children: [
              seg(allow, AppTheme.accentGreenFill),
              const SizedBox(width: 3),
              seg(block - allow, AppTheme.accentOrange),
              const SizedBox(width: 3),
              seg(100 - block, AppTheme.accentRedFill),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF0A1020) : const Color(0xFFF4F6FB);
    final card = dark ? const Color(0xFF121A30) : Colors.white;
    final accent = dark ? const Color(0xFF5B8DF6) : const Color(0xFF0A2F7A);
    final line = dark
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xFF0A1A3C).withValues(alpha: 0.12);

    return PressableScale(
      haptic: true,
      scale: 0.97,
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 112,
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: bg,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: selected ? AppTheme.primaryBlue : AppTheme.hairline,
                  width: selected ? 2.2 : 0.8,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: dark
                          ? const [Color(0xFF1A3270), Color(0xFF0A1530)]
                          : const [Color(0xFF0F3A94), Color(0xFF051640)],
                    ),
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: ShapeDecoration(
                      color: card,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 5,
                          width: 54,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: line,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppFont.main(
                  color: selected ? AppTheme.textPrimary : AppTheme.textMuted,
                  fontSize: 14.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 17,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
