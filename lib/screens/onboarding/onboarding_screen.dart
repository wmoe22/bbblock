import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ui_kit.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPage> get _pages => [
    _OnboardingPage(
      icon: Icons.shield_rounded,
      iconColor: AppTheme.primaryBlue,
      title: 'Block spam\nbefore it rings',
      subtitle:
          'Scam, spam and telemarketing calls are detected and stopped before they ever reach you.',
    ),
    _OnboardingPage(
      icon: Icons.visibility_rounded,
      iconColor: AppTheme.accentGreenFill,
      title: 'Know who\'s\nreally calling',
      subtitle:
          'See the caller category and threat level in real time, before you decide to answer.',
    ),
    _OnboardingPage(
      icon: Icons.psychology_alt_rounded,
      iconColor: AppTheme.accentPurple,
      title: 'AI that asks\nwhen unsure',
      subtitle:
          'Messages, DMs and email are triaged automatically. Anything ambiguous comes to you for a final call.',
    ),
    _OnboardingPage(
      icon: Icons.lock_rounded,
      iconColor: AppTheme.accentOrange,
      title: 'Private by\ndesign',
      subtitle:
          'Your data stays on your device. We never collect, log or share your personal information.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -140,
            left: -60,
            right: -60,
            height: 520,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(
                      alpha: AppTheme.isDark ? 0.28 : 0.12,
                    ),
                    AppTheme.primaryBlue.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                    child: AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: isLast ? null : widget.onComplete,
                        child: Text(
                          'Skip',
                          style: AppFont.main(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      AppHaptics.selection();
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) =>
                        _PageContent(page: pages[index]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pages.length, (index) {
                          final active = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            width: active ? 26 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textMuted.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: isLast ? 'Get Started' : 'Continue',
                        height: 56,
                        fontSize: 17,
                        onPressed: () {
                          if (!isLast) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                            );
                          } else {
                            widget.onComplete();
                          }
                        },
                      ),
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

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final (i, d) in const [260.0, 196.0, 140.0].indexed)
                  Container(
                        width: d,
                        height: d,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: page.iconColor.withValues(
                            alpha: AppTheme.isDark
                                ? 0.05 + i * 0.03
                                : 0.04 + i * 0.025,
                          ),
                          border: Border.all(
                            color: page.iconColor.withValues(alpha: 0.12),
                            width: 0.8,
                          ),
                        ),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        delay: Duration(milliseconds: 80 * i),
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(duration: 500.ms),
                AppIconBadge(icon: page.icon, color: page.iconColor, size: 104)
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      delay: 180.ms,
                      duration: 650.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(delay: 180.ms, duration: 400.ms),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
                page.title,
                textAlign: TextAlign.center,
                style: AppFont.main(
                  color: AppTheme.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1.1,
                ),
              )
              .animate()
              .fadeIn(delay: 250.ms, duration: 500.ms)
              .slideY(
                begin: 0.15,
                end: 0,
                delay: 250.ms,
                duration: 550.ms,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 16),
          Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: AppFont.sub(
                  color: AppTheme.textSecondary,
                  fontSize: 17,
                  height: 1.45,
                  letterSpacing: -0.3,
                ),
              )
              .animate()
              .fadeIn(delay: 350.ms, duration: 500.ms)
              .slideY(
                begin: 0.15,
                end: 0,
                delay: 350.ms,
                duration: 550.ms,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
